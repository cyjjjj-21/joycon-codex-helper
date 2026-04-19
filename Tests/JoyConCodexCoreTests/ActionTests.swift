import Testing
@testable import JoyConCodexCore

@Test
func actionNames_areStableAndExplicit() {
    #expect(Action.allCases.map(\.rawValue) == [
        "move_up",
        "move_down",
        "move_left",
        "move_right",
        "delete_left",
        "confirm",
        "voice_hold",
        "toggle_plan_mode",
        "manual_recover"
    ])
}
