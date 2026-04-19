import JoyConCodexCore

struct TargetAppConfiguration: Sendable {
    let codexBundleIdentifier: String

    init(targets: TargetAppsConfig) {
        self.codexBundleIdentifier = targets.codex.bundleIdentifier
    }
}
