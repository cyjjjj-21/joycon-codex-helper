struct AppleScriptPlanModeToggler: PlanModeToggling {
    let keyboardEmitter: KeyboardEventSending

    func toggle() throws {
        try keyboardEmitter.tap(key: "Tab", modifiers: ["Shift"])
    }
}
