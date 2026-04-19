import ApplicationServices

enum AccessibilityPermissions {
    static func isTrusted() -> Bool {
        AXIsProcessTrusted()
    }
}
