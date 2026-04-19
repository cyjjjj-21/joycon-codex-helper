import Foundation

public struct ConfigLoader {
    public init() {}

    public func loadProfile(at url: URL) throws -> Profile {
        try decode(Profile.self, at: url)
    }

    public func loadActionBindings(at url: URL) throws -> [Action: ExecutionBinding] {
        let rawBindings = try decode([String: ExecutionBinding].self, at: url)
        return try Dictionary(uniqueKeysWithValues: rawBindings.map { key, value in
            guard let action = Action(rawValue: key) else {
                throw ConfigLoaderError.unknownActionKey(key)
            }
            return (action, value)
        })
    }

    public func loadTargetApps(at url: URL) throws -> TargetAppsConfig {
        try decode(TargetAppsConfig.self, at: url)
    }

    public func loadInputAliases(at url: URL) throws -> InputAliasRegistry {
        try decode(InputAliasRegistry.self, at: url)
    }

    private func decode<T: Decodable>(_ type: T.Type, at url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

public enum ConfigLoaderError: Error, Equatable {
    case unknownActionKey(String)
}
