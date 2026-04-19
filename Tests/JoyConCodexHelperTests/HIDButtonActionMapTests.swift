import Testing
@testable import JoyConCodexCore
@testable import JoyConCodexHelper

@Test
func hidButtonActionMap_routesRawJoyConShoulderUsages() {
    let profile = Profile(
        profileName: "raw-hid-test",
        physicalToAction: [
            "ZR": .voiceHold,
            "R": .confirm,
            "R3": .togglePlanMode,
            "Home": .manualRecover
        ],
        disabledInputs: []
    )
    let aliases = InputAliasRegistry(aliases: [
        "ZR": [.init(kind: .hidButton, name: "joyConRZR", usagePage: 0x09, usage: 0x10)],
        "R": [.init(kind: .hidButton, name: "joyConRR", usagePage: 0x09, usage: 0x0f)],
        "R3": [.init(kind: .hidButton, name: "joyConRR3", usagePage: 0x09, usage: 0x0c)],
        "Home": [.init(kind: .hidButton, name: "joyConRHome", usagePage: 0x09, usage: 0x0d)]
    ])

    let map = HIDButtonActionMap(profile: profile, aliases: aliases)

    #expect(map.action(forUsagePage: 0x09, usage: 0x10) == .voiceHold)
    #expect(map.action(forUsagePage: 0x09, usage: 0x0f) == .confirm)
    #expect(map.action(forUsagePage: 0x09, usage: 0x0c) == .togglePlanMode)
    #expect(map.action(forUsagePage: 0x09, usage: 0x0d) == .manualRecover)
    #expect(map.action(forUsagePage: 0x09, usage: 0x0a) == nil)
}
