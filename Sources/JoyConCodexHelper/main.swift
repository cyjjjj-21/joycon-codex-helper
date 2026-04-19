import AppKit
import Foundation
import JoyConCodexCore

@MainActor
final class JoyConCodexAppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarStatusController?
    private var controllerMonitor: ControllerMonitor?
    private var hotkeyListener: HotkeyListener?
    private var rawHIDInputRouter: RawHIDInputRouter?
    private var keyboardEmitter: KeyboardEventSending?
    private var keyRepeater: KeyRepeating?
    private var logger: Logger?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let logger = Logger()
        self.logger = logger
        do {
            let configuration = try AppConfigurationLoader().load(from: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
            let statusStore = StatusStore(lowBatteryThreshold: configuration.controllerPreferences.lowBatteryThreshold)
            let menuBarController = MenuBarStatusController(statusStore: statusStore)
            self.menuBarController = menuBarController

            let targetConfig = TargetAppConfiguration(targets: configuration.targets)
            let frontmostAppMonitor = FrontmostAppMonitor(
                provider: WorkspaceFrontmostAppProvider(),
                target: targetConfig
            )
            let keyboardEmitter = CGEventKeyboardEmitter()
            self.keyboardEmitter = keyboardEmitter
            let keyRepeater = TimerKeyRepeater(keyboardEmitter: keyboardEmitter)
            self.keyRepeater = keyRepeater
            let planToggler = AppleScriptPlanModeToggler(keyboardEmitter: keyboardEmitter)
            let planModeRouter = PlanModeRouter(
                frontmostAppMonitor: frontmostAppMonitor,
                toggler: planToggler,
                logger: logger
            )
            let recoveryCoordinator = ControllerRecoveryCoordinator(
                logger: logger,
                releaseHeldKeys: {
                    keyRepeater.stopAll()
                    try keyboardEmitter.releaseAllHolds()
                }
            ) { [weak self] in
                self?.controllerMonitor?.refreshControllerSelection()
            }
            let actionDispatcher = ActionDispatcher(
                bindings: configuration.bindings,
                frontmostAppMonitor: frontmostAppMonitor,
                planModeRouter: planModeRouter,
                keyboardEmitter: keyboardEmitter,
                keyRepeater: keyRepeater,
                logger: logger,
                manualRecover: {
                    recoveryCoordinator.attemptRecovery()
                }
            )
            let inputRouter = ControllerInputRouter(
                profile: configuration.profile,
                aliases: configuration.inputAliases,
                actionDispatcher: actionDispatcher,
                logger: logger
            )
            let rawHIDInputRouter = RawHIDInputRouter(
                actionMap: HIDButtonActionMap(profile: configuration.profile, aliases: configuration.inputAliases),
                actionDispatcher: actionDispatcher,
                logger: logger
            )
            self.rawHIDInputRouter = rawHIDInputRouter

            let controllerMonitor = ControllerMonitor(
                statusStore: statusStore,
                controllerPreferences: configuration.controllerPreferences,
                inputRouter: inputRouter,
                logger: logger,
                releaseHeldKeys: {
                    keyRepeater.stopAll()
                    try keyboardEmitter.releaseAllHolds()
                }
            ) { [weak menuBarController] in
                menuBarController?.refresh()
            }
            self.controllerMonitor = controllerMonitor

            if let planBinding = configuration.bindings[.togglePlanMode], let hotkey = planBinding.key {
                hotkeyListener = try HotkeyListener(key: hotkey, modifiers: planBinding.modifiers ?? []) {
                    do {
                        try planModeRouter.handle(.togglePlanModeRequested)
                    } catch {
                        logger.error("Hotkey plan toggle failed: \(error)")
                    }
                }
                try hotkeyListener?.start()
            }

            if !AccessibilityPermissions.isTrusted() {
                logger.info("Accessibility permission is not granted yet; key injection will not work until it is enabled for the helper process.")
            }

            controllerMonitor.start()
            rawHIDInputRouter.start()

            logger.info("JoyConCodexHelper is running")
        } catch {
            logger.error("Failed to start JoyConCodexHelper: \(error)")
            NSApplication.shared.terminate(nil)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        keyRepeater?.stopAll()
        do {
            try keyboardEmitter?.releaseAllHolds()
        } catch {
            logger?.error("Failed to release held keys while terminating: \(error)")
        }
        rawHIDInputRouter?.stop()
    }
}

let app = NSApplication.shared
let delegate = JoyConCodexAppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
