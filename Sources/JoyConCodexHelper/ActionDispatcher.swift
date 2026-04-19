import Foundation
import JoyConCodexCore

final class ActionDispatcher {
    private let bindings: [Action: ExecutionBinding]
    private let frontmostAppMonitor: FrontmostAppMonitor
    private let planModeRouter: PlanModeRouter
    private let keyboardEmitter: KeyboardEventSending
    private let keyRepeater: KeyRepeating
    private let logger: Logger
    private let manualRecover: (() -> Void)?

    init(
        bindings: [Action: ExecutionBinding],
        frontmostAppMonitor: FrontmostAppMonitor,
        planModeRouter: PlanModeRouter,
        keyboardEmitter: KeyboardEventSending,
        keyRepeater: KeyRepeating,
        logger: Logger,
        manualRecover: (() -> Void)? = nil
    ) {
        self.bindings = bindings
        self.frontmostAppMonitor = frontmostAppMonitor
        self.planModeRouter = planModeRouter
        self.keyboardEmitter = keyboardEmitter
        self.keyRepeater = keyRepeater
        self.logger = logger
        self.manualRecover = manualRecover
    }

    func handle(action: Action, isPressed: Bool) {
        do {
            switch action {
            case .togglePlanMode:
                guard isPressed else { return }
                try planModeRouter.handle(.togglePlanModeRequested)
            case .manualRecover:
                guard isPressed else { return }
                logger.info("Manual recover requested")
                manualRecover?()
            case .voiceHold:
                guard let binding = bindings[action] else { return }
                if isPressed {
                    guard frontmostAppMonitor.isCodexFrontmost else {
                        logger.info("Ignored voice hold because Codex is not frontmost")
                        return
                    }
                    try keyboardEmitter.beginHold(key: binding.key ?? "", modifiers: binding.modifiers ?? [])
                } else {
                    try keyboardEmitter.endHold(key: binding.key ?? "", modifiers: binding.modifiers ?? [])
                }
            case .deleteLeft:
                guard let binding = bindings[action] else { return }
                if isPressed {
                    guard frontmostAppMonitor.isCodexFrontmost else {
                        logger.info("Ignored delete left because Codex is not frontmost")
                        return
                    }
                    try keyRepeater.start(key: binding.key ?? "", modifiers: binding.modifiers ?? [])
                } else {
                    try keyRepeater.stop(key: binding.key ?? "", modifiers: binding.modifiers ?? [])
                }
            default:
                guard isPressed else { return }
                guard frontmostAppMonitor.isCodexFrontmost else {
                    logger.info("Ignored \(action.rawValue) because Codex is not frontmost")
                    return
                }
                guard let binding = bindings[action] else { return }
                try keyboardEmitter.tap(key: binding.key ?? "", modifiers: binding.modifiers ?? [])
            }
        } catch {
            logger.error("Failed to handle \(action.rawValue): \(error)")
        }
    }
}
