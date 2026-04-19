import Carbon.HIToolbox
import Testing
@testable import JoyConCodexHelper

@Test
func tap_releasesMainKeyBeforeModifierKeys() throws {
    let poster = RecordingKeyboardEventPoster()
    let emitter = CGEventKeyboardEmitter(eventPoster: poster)

    try emitter.tap(key: "M", modifiers: ["Control"])

    #expect(poster.events.map(\.keyCode) == [
        CGKeyCode(kVK_Control),
        CGKeyCode(kVK_ANSI_M),
        CGKeyCode(kVK_ANSI_M),
        CGKeyCode(kVK_Control)
    ])
    #expect(poster.events.map(\.keyDown) == [true, true, false, false])
}

@Test
func releaseAllHolds_releasesHeldShortcutAndAllowsHoldingAgain() throws {
    let poster = RecordingKeyboardEventPoster()
    let emitter = CGEventKeyboardEmitter(eventPoster: poster)

    try emitter.beginHold(key: "M", modifiers: ["Control"])
    try emitter.releaseAllHolds()
    try emitter.beginHold(key: "M", modifiers: ["Control"])

    #expect(poster.events.map(\.keyCode) == [
        CGKeyCode(kVK_Control),
        CGKeyCode(kVK_ANSI_M),
        CGKeyCode(kVK_ANSI_M),
        CGKeyCode(kVK_Control),
        CGKeyCode(kVK_Control),
        CGKeyCode(kVK_ANSI_M)
    ])
    #expect(poster.events.map(\.keyDown) == [true, true, false, false, true, true])
}

private final class RecordingKeyboardEventPoster: KeyboardEventPosting {
    struct Event {
        let keyCode: CGKeyCode
        let keyDown: Bool
        let flags: CGEventFlags
    }

    private(set) var events: [Event] = []

    func post(keyCode: CGKeyCode, keyDown: Bool, flags: CGEventFlags) throws {
        events.append(.init(keyCode: keyCode, keyDown: keyDown, flags: flags))
    }
}
