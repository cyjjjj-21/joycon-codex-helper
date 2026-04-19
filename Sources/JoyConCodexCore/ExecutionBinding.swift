public enum ExecutionBindingType: String, Codable, Sendable, Equatable {
    case key
    case keyComboHold
    case emitHotkey
    case noOpHint
}

public struct ExecutionBinding: Codable, Sendable, Equatable {
    public let type: ExecutionBindingType
    public let key: String?
    public let modifiers: [String]?
    public let label: String?

    public init(type: ExecutionBindingType, key: String?, modifiers: [String]?, label: String?) {
        self.type = type
        self.key = key
        self.modifiers = modifiers
        self.label = label
    }
}

public struct TargetAppRecord: Codable, Sendable, Equatable {
    public let bundleIdentifier: String

    public init(bundleIdentifier: String) {
        self.bundleIdentifier = bundleIdentifier
    }
}

public struct TargetAppsConfig: Codable, Sendable, Equatable {
    public let codex: TargetAppRecord

    public init(codex: TargetAppRecord) {
        self.codex = codex
    }
}
