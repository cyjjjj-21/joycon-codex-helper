import AppKit

protocol FrontmostAppProviding {
    var frontmostBundleIdentifier: String? { get }
}

struct WorkspaceFrontmostAppProvider: FrontmostAppProviding {
    var frontmostBundleIdentifier: String? {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }
}

struct FrontmostAppMonitor {
    let provider: FrontmostAppProviding
    let target: TargetAppConfiguration

    var isCodexFrontmost: Bool {
        provider.frontmostBundleIdentifier == target.codexBundleIdentifier
    }
}
