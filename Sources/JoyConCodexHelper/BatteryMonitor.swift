import AppKit
@preconcurrency import Foundation
@preconcurrency import GameController

final class BatteryMonitor: NSObject {
    private let statusStore: StatusStore
    private let threshold: Float
    private let onStatusChange: () -> Void
    private var timer: Timer?
    private var lowBatteryAlertActive = false
    private var controllerProvider: (() -> GCController?)?

    init(
        statusStore: StatusStore,
        threshold: Float,
        onStatusChange: @escaping () -> Void
    ) {
        self.statusStore = statusStore
        self.threshold = threshold
        self.onStatusChange = onStatusChange
        super.init()
    }

    func start(with controllerProvider: @escaping () -> GCController?, pollInterval: TimeInterval) {
        self.controllerProvider = controllerProvider
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: pollInterval, target: self, selector: #selector(pollTimerFired), userInfo: nil, repeats: true)
        poll()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        controllerProvider = nil
        statusStore.updateBattery(level: nil, state: nil)
        onStatusChange()
    }

    @objc
    private func pollTimerFired() {
        poll()
    }

    private func poll() {
        guard let battery = controllerProvider?()?.battery else {
            statusStore.updateBattery(level: nil, state: nil)
            lowBatteryAlertActive = false
            onStatusChange()
            return
        }

        let mappedState: BatteryChargeState? = switch battery.batteryState {
        case .charging:
            BatteryChargeState.charging
        case .full:
            BatteryChargeState.full
        case .discharging:
            BatteryChargeState.discharging
        default:
            nil
        }

        statusStore.updateBattery(level: battery.batteryLevel, state: mappedState)
        let shouldAlert = statusStore.snapshot.lowBatteryWarning && battery.batteryLevel <= threshold
        if shouldAlert && !lowBatteryAlertActive {
            NSSound.beep()
        }
        lowBatteryAlertActive = shouldAlert
        onStatusChange()
    }
}
