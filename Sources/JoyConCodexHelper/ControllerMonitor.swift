@preconcurrency import Foundation
@preconcurrency import GameController

final class ControllerMonitor: NSObject {
    private let statusStore: StatusStore
    private let controllerPreferences: ControllerPreferences
    private let inputRouter: ControllerInputRouter
    private let logger: Logger
    private let releaseHeldKeys: () throws -> Void
    private let onConnectionChange: () -> Void
    private var currentController: GCController?

    init(
        statusStore: StatusStore,
        controllerPreferences: ControllerPreferences,
        inputRouter: ControllerInputRouter,
        logger: Logger,
        releaseHeldKeys: @escaping () throws -> Void = {},
        onConnectionChange: @escaping () -> Void
    ) {
        self.statusStore = statusStore
        self.controllerPreferences = controllerPreferences
        self.inputRouter = inputRouter
        self.logger = logger
        self.releaseHeldKeys = releaseHeldKeys
        self.onConnectionChange = onConnectionChange
        super.init()
    }

    func start() {
        GCController.shouldMonitorBackgroundEvents = true

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(controllerDidChange), name: .GCControllerDidConnect, object: nil)
        notificationCenter.addObserver(self, selector: #selector(controllerDidChange), name: .GCControllerDidDisconnect, object: nil)

        refreshControllerSelection()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func refreshControllerSelection() {
        let nextController = preferredController(from: GCController.controllers())

        guard nextController !== currentController else {
            updateStatus()
            return
        }

        if let currentController {
            releaseHeldKeysForControllerChange()
            inputRouter.unwire(controller: currentController)
        }
        currentController = nextController
        if let currentController {
            logger.info("Selected controller: \(currentController.vendorName ?? currentController.productCategory)")
            inputRouter.wire(controller: currentController)
        } else {
            logger.info("No preferred controller is currently connected")
        }

        updateStatus()
    }

    func selectedController() -> GCController? {
        currentController
    }

    private func preferredController(from controllers: [GCController]) -> GCController? {
        guard !controllers.isEmpty else {
            return nil
        }

        for preferredName in controllerPreferences.preferredControllerNameContains {
            if let match = controllers.first(where: { controller in
                let haystacks = [
                    controller.vendorName ?? "",
                    controller.productCategory
                ]
                return haystacks.contains(where: { $0.localizedCaseInsensitiveContains(preferredName) })
            }) {
                return match
            }
        }

        let joyConCandidates = controllers.filter { controller in
            let haystacks = [
                controller.vendorName ?? "",
                controller.productCategory
            ]
            return haystacks.contains(where: { $0.localizedCaseInsensitiveContains("Joy-Con") })
        }
        if joyConCandidates.count == 1 {
            return joyConCandidates.first
        }

        return controllers.count == 1 ? controllers.first : nil
    }

    private func updateStatus() {
        if let currentController {
            let name = currentController.vendorName ?? currentController.productCategory
            statusStore.updateConnection(controllerName: name, isConnected: true)
        } else {
            statusStore.updateConnection(controllerName: nil, isConnected: false)
        }

        onConnectionChange()
    }

    @objc
    private func controllerDidChange() {
        refreshControllerSelection()
    }

    private func releaseHeldKeysForControllerChange() {
        do {
            try releaseHeldKeys()
        } catch {
            logger.error("Failed to release held keys during controller change: \(error)")
        }
    }
}
