import Testing
@testable import JoyConCodexHelper
@testable import JoyConCodexCore

@Test
func targetAppConfiguration_usesLoadedConfigAsSingleSourceOfTruth() {
    let config = TargetAppsConfig(codex: .init(bundleIdentifier: "com.openai.codex"))
    let targetConfig = TargetAppConfiguration(targets: config)

    #expect(targetConfig.codexBundleIdentifier == "com.openai.codex")
}

@Test
func frontmostAppMonitor_matchesConfiguredBundleIdentifier() {
    let targetConfig = TargetAppConfiguration(targets: .init(codex: .init(bundleIdentifier: "com.openai.codex")))

    let matchingMonitor = FrontmostAppMonitor(
        provider: FakeFrontmostAppProvider(frontmostBundleIdentifier: "com.openai.codex"),
        target: targetConfig
    )
    #expect(matchingMonitor.isCodexFrontmost)

    let otherMonitor = FrontmostAppMonitor(
        provider: FakeFrontmostAppProvider(frontmostBundleIdentifier: "com.example.other"),
        target: targetConfig
    )
    #expect(!otherMonitor.isCodexFrontmost)

    let missingMonitor = FrontmostAppMonitor(
        provider: FakeFrontmostAppProvider(frontmostBundleIdentifier: nil),
        target: targetConfig
    )
    #expect(!missingMonitor.isCodexFrontmost)
}

@Test
func planModeRouter_onlyTogglesWhenCodexIsFrontmost() throws {
    let toggler = RecordingPlanModeToggler()
    let logger = Logger()

    let activeRouter = PlanModeRouter(
        frontmostAppMonitor: FrontmostAppMonitor(
            provider: FakeFrontmostAppProvider(frontmostBundleIdentifier: "com.openai.codex"),
            target: .init(targets: .init(codex: .init(bundleIdentifier: "com.openai.codex")))
        ),
        toggler: toggler,
        logger: logger
    )

    try activeRouter.handle(.togglePlanModeRequested)
    #expect(toggler.toggleCount == 1)

    let inactiveToggler = RecordingPlanModeToggler()
    let inactiveRouter = PlanModeRouter(
        frontmostAppMonitor: FrontmostAppMonitor(
            provider: FakeFrontmostAppProvider(frontmostBundleIdentifier: "com.example.other"),
            target: .init(targets: .init(codex: .init(bundleIdentifier: "com.openai.codex")))
        ),
        toggler: inactiveToggler,
        logger: logger
    )

    try inactiveRouter.handle(.togglePlanModeRequested)
    #expect(inactiveToggler.toggleCount == 0)
}

private struct FakeFrontmostAppProvider: FrontmostAppProviding {
    let frontmostBundleIdentifier: String?
}

private final class RecordingPlanModeToggler: PlanModeToggling {
    private(set) var toggleCount = 0

    func toggle() throws {
        toggleCount += 1
    }
}
