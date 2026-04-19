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
        menu.addItem(NSMenuItem.separator())
        menu.addItem(menuItem(title: "Quit JoyConCodexHelper", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        refresh()
    }

    func statusSummary() -> String {
        switch statusStore.snapshot.connection {
        case .disconnected:
            return "JC offline"
        case let .connected(name):
            switch statusStore.snapshot.battery {
            case .unavailable:
                return "\(shortName(name)) on"
            case let .available(level, _):
                let percent = Int(level * 100)
                return statusStore.snapshot.lowBatteryWarning ? "\(shortName(name)) LOW \(percent)%" : "\(shortName(name)) \(percent)%"
            }
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

    private func shortName(_ name: String) -> String {
        if name.localizedCaseInsensitiveContains("Joy-Con") {
            return "Joy-Con"
        }
        return name
    }

    @objc
    private func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc
    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
