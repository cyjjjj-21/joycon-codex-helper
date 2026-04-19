public enum Action: String, CaseIterable, Codable, Sendable {
    case moveUp = "move_up"
    case moveDown = "move_down"
    case moveLeft = "move_left"
    case moveRight = "move_right"
    case deleteLeft = "delete_left"
    case confirm = "confirm"
    case voiceHold = "voice_hold"
    case togglePlanMode = "toggle_plan_mode"
    case manualRecover = "manual_recover"
}
