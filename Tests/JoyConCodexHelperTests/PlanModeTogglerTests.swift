import Testing
@testable import JoyConCodexHelper

@Test
func planModeToggle_sendsShiftTabShortcut() throws {
    let keyboardEmitter = RecordingKeyboardEmitter()
    let toggler = AppleScriptPlanModeToggler(keyboardEmitter: keyboardEmitter)

    try toggler.toggle()

    #expect(keyboardEmitter.taps.count == 1)
    #expect(keyboardEmitter.taps.first?.key == "Tab")
    #expect(keyboardEmitter.taps.first?.modifiers == ["Shift"])
}

private final class RecordingKeyboardEmitter: KeyboardEventSending {
    struct TapRecord {
        let key: String
        let modifiers: [String]
    }

    private(set) var taps: [TapRecord] = []

    func tap(key: String, modifiers: [String]) throws {
        taps.append(.init(key: key, modifiers: modifiers))
    }

    func beginHold(key: String, modifiers: [String]) throws {}

    func endHold(key: String, modifiers: [String]) throws {}

    func releaseAllHolds() throws {}
}
