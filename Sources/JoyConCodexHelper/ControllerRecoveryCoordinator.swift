import Foundation
import GameController

final class ControllerRecoveryCoordinator: NSObject {
    private let logger: Logger
    private let releaseHeldKeys: () throws -> Void
    private let refreshSelection: () -> Void
    private var stopTimer: Timer?

    init(
        logger: Logger,
        releaseHeldKeys: @escaping () throws -> Void = {},
        refreshSelection: @escaping () -> Void
    ) {
        self.logger = logger
        self.releaseHeldKeys = releaseHeldKeys
        self.refreshSelection = refreshSelection
        super.init()
    }

    func attemptRecovery() {
        logger.info("Starting wireless controller recovery scan")
        releaseHeldKeysForRecovery()
        stopTimer?.invalidate()
        GCController.stopWirelessControllerDiscovery()
        GCController.startWirelessControllerDiscovery(completionHandler: nil)
        stopTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(finishRecovery), userInfo: nil, repeats: false)
    }

    @objc
    private func finishRecovery() {
        GCController.stopWirelessControllerDiscovery()
        refreshSelection()
        logger.info("Finished wireless controller recovery scan")
    }

    private func releaseHeldKeysForRecovery() {
        do {
            try releaseHeldKeys()
        } catch {
            logger.error("Failed to release held keys before recovery scan: \(error)")
        }
    }
}
