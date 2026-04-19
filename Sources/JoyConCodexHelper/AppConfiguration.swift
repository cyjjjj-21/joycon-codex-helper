import Foundation
import JoyConCodexCore

struct AppConfiguration {
    let profile: Profile
    let bindings: [Action: ExecutionBinding]
    let targets: TargetAppsConfig
    let inputAliases: InputAliasRegistry
    let controllerPreferences: ControllerPreferences
}

enum AppConfigurationError: Error {
    case missingConfigDirectory
}

struct AppConfigurationLoader {
    private let loader = ConfigLoader()
    private let validator = ConfigValidator()

    func load(from root: URL) throws -> AppConfiguration {
        let configRoot = try locateConfigRoot(startingFrom: root)
        guard FileManager.default.fileExists(atPath: configRoot.path) else {
            throw AppConfigurationError.missingConfigDirectory
        }

        let profile = try loader.loadProfile(at: configRoot.appendingPathComponent("profiles/layout-v1-default.json"))
        let bindings = try loader.loadActionBindings(at: configRoot.appendingPathComponent("bindings/default-actions.json"))
        let targets = try loader.loadTargetApps(at: configRoot.appendingPathComponent("runtime/target-apps.json"))
        let inputAliases = try loader.loadInputAliases(at: configRoot.appendingPathComponent("runtime/input-aliases.json"))

        let preferenceData = try Data(contentsOf: configRoot.appendingPathComponent("runtime/controller-preferences.json"))
        let controllerPreferences = try JSONDecoder().decode(ControllerPreferences.self, from: preferenceData)

        try validator.validate(
            profile: profile,
            bindings: bindings,
            targets: targets,
            inputAliases: inputAliases
        )

        return AppConfiguration(
            profile: profile,
            bindings: bindings,
            targets: targets,
            inputAliases: inputAliases,
            controllerPreferences: controllerPreferences
        )
    }

    private func locateConfigRoot(startingFrom root: URL) throws -> URL {
        let fileManager = FileManager.default
        var candidates: [URL] = [root]

        if let executableURL = Bundle.main.executableURL {
            candidates.append(executableURL.deletingLastPathComponent())
        }

        for candidate in candidates {
            var current = candidate
            for _ in 0..<8 {
                let configRoot = current.appendingPathComponent("config", isDirectory: true)
                let profilePath = configRoot.appendingPathComponent("profiles/layout-v1-default.json").path
                if fileManager.fileExists(atPath: profilePath) {
                    return configRoot
                }
                let parent = current.deletingLastPathComponent()
                if parent.path == current.path {
                    break
                }
                current = parent
            }
        }

        throw AppConfigurationError.missingConfigDirectory
    }
}
