import Foundation
import Testing
@testable import JoyConCodexCore

@Test
func validConfig_loadsAndValidates() throws {
    let root = projectRoot()
    let loader = ConfigLoader()
    let validator = ConfigValidator()

    let profile = try loader.loadProfile(at: root.appending(path: "config/profiles/layout-v1-default.json"))
    let bindings = try loader.loadActionBindings(at: root.appending(path: "config/bindings/default-actions.json"))
    let targets = try loader.loadTargetApps(at: root.appending(path: "config/runtime/target-apps.json"))
    let aliases = try loader.loadInputAliases(at: root.appending(path: "config/runtime/input-aliases.json"))

    #expect(profile.profileName == "layout-v1-default")
    #expect(profile.disabledInputs.contains("SL"))
    #expect(profile.disabledInputs.contains("SR"))
    #expect(bindings[.togglePlanMode]?.type == .emitHotkey)
    #expect(targets.codex.bundleIdentifier == "com.openai.codex")
    #expect(aliases.aliases["R3"]?.first?.name == "rightThumbstickButton")

    try validator.validate(profile: profile, bindings: bindings, targets: targets, inputAliases: aliases)
}

@Test
func duplicateActionAssignments_areRejected() throws {
    let profile = Profile(
        profileName: "dup-layout",
        physicalToAction: [
            "X": .moveUp,
            "B": .moveDown,
            "Y": .moveUp
        ],
        disabledInputs: ["RightStickUp", "RightStickDown", "RightStickLeft", "RightStickRight", "SL", "SR"]
    )

    let validator = ConfigValidator()

    #expect(throws: ConfigValidationError.self) {
        try validator.validate(profile: profile, bindings: sampleBindings(), targets: sampleTargets(), inputAliases: sampleAliases())
    }
}

@Test
func togglePlanMode_mustUseHelperHotkeyBinding() throws {
    var bindings = sampleBindings()
    bindings[.togglePlanMode] = ExecutionBinding(type: .key, key: "P", modifiers: nil, label: nil)

    let validator = ConfigValidator()

    #expect(throws: ConfigValidationError.self) {
        try validator.validate(profile: sampleProfile(), bindings: bindings, targets: sampleTargets(), inputAliases: sampleAliases())
    }
}

@Test
func targetAppsConfig_isRequired() throws {
    let invalidTargets = TargetAppsConfig(codex: .init(bundleIdentifier: ""))
    let validator = ConfigValidator()

    #expect(throws: ConfigValidationError.self) {
        try validator.validate(profile: sampleProfile(), bindings: sampleBindings(), targets: invalidTargets, inputAliases: sampleAliases())
    }
}

@Test
func mappedInputs_requireAliasTargets() throws {
    let validator = ConfigValidator()
    let aliases = InputAliasRegistry(aliases: ["X": [.init(kind: .button, name: "x")]])

    #expect(throws: ConfigValidationError.self) {
        try validator.validate(profile: sampleProfile(), bindings: sampleBindings(), targets: sampleTargets(), inputAliases: aliases)
    }
}

private func projectRoot() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}

private func sampleProfile() -> Profile {
    Profile(
        profileName: "layout-v1-default",
        physicalToAction: [
            "X": .moveUp,
            "B": .moveDown,
            "Y": .moveLeft,
            "A": .moveRight,
            "ZR": .voiceHold,
            "R": .confirm,
            "+": .deleteLeft,
            "R3": .togglePlanMode,
            "Home": .manualRecover
        ],
        disabledInputs: ["RightStickUp", "RightStickDown", "RightStickLeft", "RightStickRight", "SL", "SR"]
    )
}

private func sampleBindings() -> [Action: ExecutionBinding] {
    [
        .moveUp: .init(type: .key, key: "UpArrow", modifiers: nil, label: nil),
        .moveDown: .init(type: .key, key: "DownArrow", modifiers: nil, label: nil),
        .moveLeft: .init(type: .key, key: "LeftArrow", modifiers: nil, label: nil),
        .moveRight: .init(type: .key, key: "RightArrow", modifiers: nil, label: nil),
        .deleteLeft: .init(type: .key, key: "Backspace", modifiers: nil, label: nil),
        .confirm: .init(type: .key, key: "Return", modifiers: nil, label: nil),
        .voiceHold: .init(type: .keyComboHold, key: "M", modifiers: ["Control"], label: nil),
        .togglePlanMode: .init(type: .emitHotkey, key: "F18", modifiers: nil, label: nil),
        .manualRecover: .init(type: .noOpHint, key: nil, modifiers: nil, label: "manual recover attempt")
    ]
}

private func sampleTargets() -> TargetAppsConfig {
    .init(codex: .init(bundleIdentifier: "com.openai.codex"))
}

private func sampleAliases() -> InputAliasRegistry {
    .init(aliases: [
        "X": [.init(kind: .button, name: "x")],
        "B": [.init(kind: .button, name: "b")],
        "Y": [.init(kind: .button, name: "y")],
        "A": [.init(kind: .button, name: "a")],
        "ZR": [.init(kind: .button, name: "rightTrigger")],
        "R": [.init(kind: .button, name: "rightShoulder")],
        "+": [.init(kind: .button, name: "menu")],
        "R3": [.init(kind: .button, name: "rightThumbstickButton")],
        "Home": [.init(kind: .button, name: "home")]
    ])
}
