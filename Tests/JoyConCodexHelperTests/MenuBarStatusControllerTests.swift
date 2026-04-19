import AppKit
import Testing
@testable import JoyConCodexHelper

@MainActor
@Test
func menuItems_haveExplicitTargetsSoTheyStayEnabled() {
    let controller = MenuBarStatusController(statusStore: StatusStore())
    let menu = statusItem(from: controller).menu
    let actionableItems = menu?.items.filter { !$0.isSeparatorItem } ?? []

    #expect(actionableItems.count == 2)
    for item in actionableItems {
        #expect(item.target === controller)
        #expect(item.isEnabled)
    }
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
