import AppKit
import Testing
@testable import JoyConCodexHelper

@MainActor
@Test
func menuItems_haveExplicitTargetsSoTheyStayEnabled() {
    let controller = MenuBarStatusController(statusStore: StatusStore())
    let menu = statusItem(from: controller).menu
    let actionableItems = menu?.items.filter { !$0.isSeparatorItem } ?? []

    #expect(actionableItems.map(\.title) == [
        "Open Accessibility Settings",
        "Open Bluetooth Settings",
        "Quit JoyConCodexHelper"
    ])
    for item in actionableItems {
        #expect(item.target === controller)
        #expect(item.isEnabled)
    }
}

@MainActor
@Test
func disconnectedController_showsOfflineSummary() {
    let controller = MenuBarStatusController(statusStore: StatusStore())

    #expect(controller.statusSummary() == "Joy-Con offline")
}

@MainActor
@Test
func connectedController_showsOnSummaryWithoutBatteryDetails() {
    let store = StatusStore()
    store.updateConnection(controllerName: "Joy-Con (R)", isConnected: true)
    store.updateBattery(level: 0.12, state: .discharging)
    let controller = MenuBarStatusController(statusStore: store)

    #expect(controller.statusSummary() == "Joy-Con on")
}

@MainActor
private func statusItem(from controller: MenuBarStatusController) -> NSStatusItem {
    let mirror = Mirror(reflecting: controller)
    let child = mirror.children.first { $0.label == "statusItem" }
    guard let statusItem = child?.value as? NSStatusItem else {
        fatalError("MenuBarStatusController no longer stores statusItem directly")
    }
    return statusItem
}
