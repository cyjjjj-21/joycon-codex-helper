import Foundation

public enum ConfigValidationError: Error, Equatable {
    case duplicateActionAssignments([Action])
    case missingDisabledInputs([String])
    case invalidTogglePlanModeBinding
    case missingTargetBundleIdentifier
    case missingInputAliases([String])
}

public struct ConfigValidator {
    private let requiredDisabledInputs = [
        "RightStickUp",
        "RightStickDown",
        "RightStickLeft",
        "RightStickRight",
        "SL",
        "SR"
    ]

    public init() {}

    public func validate(
        profile: Profile,
        bindings: [Action: ExecutionBinding],
        targets: TargetAppsConfig,
        inputAliases: InputAliasRegistry
    ) throws {
        let duplicates = Dictionary(grouping: profile.physicalToAction.values, by: { $0 })
            .compactMap { action, mappedInputs in
                mappedInputs.count > 1 ? action : nil
            }
            .sorted { $0.rawValue < $1.rawValue }

        if !duplicates.isEmpty {
            throw ConfigValidationError.duplicateActionAssignments(duplicates)
        }

        let missingDisabledInputs = requiredDisabledInputs.filter { !profile.disabledInputs.contains($0) }
        if !missingDisabledInputs.isEmpty {
            throw ConfigValidationError.missingDisabledInputs(missingDisabledInputs)
        }

        guard let toggleBinding = bindings[.togglePlanMode], toggleBinding.type == .emitHotkey, toggleBinding.key?.isEmpty == false else {
            throw ConfigValidationError.invalidTogglePlanModeBinding
        }

        guard !targets.codex.bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ConfigValidationError.missingTargetBundleIdentifier
        }

        let missingInputAliases = profile.physicalToAction.keys
            .filter { inputAliases.aliases[$0]?.isEmpty != false }
            .sorted()
        if !missingInputAliases.isEmpty {
            throw ConfigValidationError.missingInputAliases(missingInputAliases)
        }
    }
}
