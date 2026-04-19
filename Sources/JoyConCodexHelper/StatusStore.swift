enum BatteryChargeState: Equatable, Sendable {
    case charging
    case discharging
    case full
}

enum ControllerConnectionStatus: Equatable, Sendable {
    case disconnected
    case connected(name: String)
}

enum ControllerBatteryStatus: Equatable, Sendable {
    case unavailable
    case available(level: Float, state: BatteryChargeState)
}

struct ControllerStatusSnapshot: Equatable, Sendable {
    var connection: ControllerConnectionStatus = .disconnected
    var battery: ControllerBatteryStatus = .unavailable
    var lowBatteryThreshold: Float = 0.2

    var lowBatteryWarning: Bool {
        guard case let .available(level, state) = battery else {
            return false
        }

        return state == .discharging && level <= lowBatteryThreshold
    }
}

final class StatusStore {
    private(set) var snapshot: ControllerStatusSnapshot

    init(lowBatteryThreshold: Float = 0.2) {
        snapshot = ControllerStatusSnapshot(lowBatteryThreshold: lowBatteryThreshold)
    }

    func updateConnection(controllerName: String?, isConnected: Bool) {
        guard isConnected, let controllerName, !controllerName.isEmpty else {
            snapshot.connection = .disconnected
            snapshot.battery = .unavailable
            return
        }

        snapshot.connection = .connected(name: controllerName)
    }

    func updateBattery(level: Float?, state: BatteryChargeState?) {
        guard
            snapshot.connection != .disconnected,
            let level,
            let state
        else {
            snapshot.battery = .unavailable
            return
        }

        snapshot.battery = .available(level: level, state: state)
    }
}
