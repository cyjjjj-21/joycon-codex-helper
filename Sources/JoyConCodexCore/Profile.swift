public struct Profile: Codable, Sendable, Equatable {
    public let profileName: String
    public let physicalToAction: [String: Action]
    public let disabledInputs: [String]

    public init(profileName: String, physicalToAction: [String: Action], disabledInputs: [String]) {
        self.profileName = profileName
        self.physicalToAction = physicalToAction
        self.disabledInputs = disabledInputs
    }
}
