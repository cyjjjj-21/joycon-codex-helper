public enum InputAliasKind: String, Codable, Sendable, Equatable {
    case button
    case dpadDirection
}

public enum InputAliasDirection: String, Codable, Sendable, Equatable {
    case up
    case down
    case left
    case right
}

public struct InputAliasTarget: Codable, Sendable, Equatable {
    public let kind: InputAliasKind
    public let name: String
    public let direction: InputAliasDirection?

    public init(kind: InputAliasKind, name: String, direction: InputAliasDirection? = nil) {
        self.kind = kind
        self.name = name
        self.direction = direction
    }
}

public struct InputAliasRegistry: Codable, Sendable, Equatable {
    public let aliases: [String: [InputAliasTarget]]

    public init(aliases: [String: [InputAliasTarget]]) {
        self.aliases = aliases
    }
}
