import Testing
@testable import JoyConCodexCore
@testable import JoyConCodexHelper

@Test
func deleteLeft_startsRepeatingBackspaceUntilRelease() {
    let repeater = RecordingKeyRepeater()
    let dispatcher = makeDispatcher(keyRepeater: repeater)

    dispatcher.handle(action: .deleteLeft, isPressed: true)
    dispatcher.handle(action: .deleteLeft, isPressed: false)

    #expect(repeater.starts == [.init(key: "Backspace", modifiers: [])])
    #expect(repeater.stops == [.init(key: "Backspace", modifiers: [])])
}

@Test
func deleteLeft_doesNotRepeatWhenCodexIsNotFrontmost() {
    let repeater = RecordingKeyRepeater()
    let dispatcher = makeDispatcher(frontmostBundleIdentifier: "com.example.other", keyRepeater: repeater)

    dispatcher.handle(action: .deleteLeft, isPressed: true)

    #expect(repeater.starts.isEmpty)
}

private func makeDispatcher(
    frontmostBundleIdentifier: String = "com.openai.codex",
    keyRepeater: KeyRepeating
) -> ActionDispatcher {
    let targetConfig = TargetAppConfiguration(targets: .init(codex: .init(bundleIdentifier: "com.openai.codex")))
    let frontmostAppMonitor = FrontmostAppMonitor(
        provider: ActionDispatcherFakeFrontmostAppProvider(frontmostBundleIdentifier: frontmostBundleIdentifier),
        target: targetConfig
    )
    let planModeRouter = PlanModeRouter(
        frontmostAppMonitor: frontmostAppMonitor,
        toggler: ActionDispatcherRecordingPlanModeToggler(),
        logger: Logger()
    )

    return ActionDispatcher(
        bindings: [.deleteLeft: .init(type: .key, key: "Backspace", modifiers: nil, label: nil)],
        frontmostAppMonitor: frontmostAppMonitor,
        planModeRouter: planModeRouter,
        keyboardEmitter: ActionDispatcherRecordingKeyboardEmitter(),
        keyRepeater: keyRepeater,
        logger: Logger()
    )
}

private struct ActionDispatcherFakeFrontmostAppProvider: FrontmostAppProviding {
    let frontmostBundleIdentifier: String?
}

private final class ActionDispatcherRecordingPlanModeToggler: PlanModeToggling {
    func toggle() throws {}
}

private final class ActionDispatcherRecordingKeyboardEmitter: KeyboardEventSending {
    func tap(key: String, modifiers: [String]) throws {}
    func beginHold(key: String, modifiers: [String]) throws {}
    func endHold(key: String, modifiers: [String]) throws {}
    func releaseAllHolds() throws {}
}

private final class RecordingKeyRepeater: KeyRepeating {
    struct Record: Equatable {
        let key: String
        let modifiers: [String]
    }

    private(set) var starts: [Record] = []
    private(set) var stops: [Record] = []

    func start(key: String, modifiers: [String]) throws {
        starts.append(.init(key: key, modifiers: modifiers))
    }

    func stop(key: String, modifiers: [String]) throws {
        stops.append(.init(key: key, modifiers: modifiers))
    }

    func stopAll() {}
}
