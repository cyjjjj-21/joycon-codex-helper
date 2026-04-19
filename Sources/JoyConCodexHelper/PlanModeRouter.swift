enum HelperEvent {
    case togglePlanModeRequested
}

struct PlanModeRouter {
    let frontmostAppMonitor: FrontmostAppMonitor
    let toggler: PlanModeToggling
    let logger: Logger

    func handle(_ event: HelperEvent) throws {
        switch event {
        case .togglePlanModeRequested:
            guard frontmostAppMonitor.isCodexFrontmost else {
                logger.info("Ignored Plan mode toggle because Codex is not frontmost")
                return
            }

            try toggler.toggle()
            logger.info("Triggered Plan mode toggle")
        }
    }
}
