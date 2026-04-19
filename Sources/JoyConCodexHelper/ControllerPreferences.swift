import Foundation

struct ControllerPreferences: Codable, Equatable, Sendable {
    let preferredControllerNameContains: [String]
    let batteryPollIntervalSeconds: TimeInterval
    let lowBatteryThreshold: Float
}
