import AppKit
import Foundation

@MainActor
final class MenuBarStatusController: NSObject {
    let statusStore: StatusStore
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    init(statusStore: StatusStore) {
        self.statusStore = statusStore
        super.init()
        let menu = NSMenu()
        menu.addItem(menuItem(title: "Open Accessibility Settings", action: #selector(openAccessibilitySettings), keyEquivalent: ""))
        menu.addItem(menuItem(title: "Open Bluetooth Settings", action: #selector(openBluetoothSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(menuItem(title: "Quit JoyConCodexHelper", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        refresh()
    }

    func statusSummary() -> String {
        switch statusStore.snapshot.connection {
        case .disconnected:
            return "Joy-Con offline"
        case .connected:
            return "Joy-Con on"
        }
    }

    func refresh() {
        statusItem.button?.title = statusSummary()
    }

    private func menuItem(title: String, action: Selector, keyEquivalent: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        item.isEnabled = true
        return item
    }
    @objc
    private func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc
    private func openBluetoothSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.BluetoothSettings") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc
    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
