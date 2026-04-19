import JoyConCodexCore

struct HIDButtonActionMap {
    private let actionsByButton: [HIDButtonKey: Action]

    init(profile: Profile, aliases: InputAliasRegistry) {
        var actionsByButton: [HIDButtonKey: Action] = [:]

        for (physicalInput, action) in profile.physicalToAction {
            let hidTargets = aliases.aliases[physicalInput, default: []].filter { $0.kind == .hidButton }
            for target in hidTargets {
                guard let usagePage = target.usagePage, let usage = target.usage else {
                    continue
                }

                actionsByButton[HIDButtonKey(usagePage: usagePage, usage: usage)] = action
            }
        }

        self.actionsByButton = actionsByButton
    }

    func action(forUsagePage usagePage: Int, usage: Int) -> Action? {
        actionsByButton[HIDButtonKey(usagePage: usagePage, usage: usage)]
    }
}

private struct HIDButtonKey: Hashable {
    let usagePage: Int
    let usage: Int
}
