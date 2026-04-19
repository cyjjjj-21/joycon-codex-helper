import Carbon.HIToolbox

final class HotkeyListener {
    private let keyCode: UInt32
    private let modifiers: UInt32
    private let handler: () -> Void
    private var eventHandlerRef: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?

    init(key: String, modifiers: [String], handler: @escaping () -> Void) throws {
        self.keyCode = try HotkeyListener.keyCode(for: key)
        self.modifiers = try HotkeyListener.modifierFlags(for: modifiers)
        self.handler = handler
    }

    deinit {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
    }

    func start() throws {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, _, userData in
            guard let userData else { return noErr }
            let listener = Unmanaged<HotkeyListener>.fromOpaque(userData).takeUnretainedValue()
            listener.handler()
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )

        let hotKeyID = EventHotKeyID(signature: fourCharCode("JCHP"), id: 1)
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        if status != noErr {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    private static func keyCode(for key: String) throws -> UInt32 {
        switch key {
        case "F18":
            UInt32(kVK_F18)
        default:
            throw KeyboardEmitterError.unsupportedKey(key)
        }
    }

    private static func modifierFlags(for modifiers: [String]) throws -> UInt32 {
        try modifiers.reduce(into: UInt32(0)) { partialResult, modifier in
            switch modifier {
            case "Shift":
                partialResult |= UInt32(shiftKey)
            case "Control":
                partialResult |= UInt32(controlKey)
            case "Option":
                partialResult |= UInt32(optionKey)
            case "Command":
                partialResult |= UInt32(cmdKey)
            default:
                throw KeyboardEmitterError.unsupportedKey(modifier)
            }
        }
    }
}

private func fourCharCode(_ string: String) -> OSType {
    string.utf8.reduce(0) { partialResult, byte in
        (partialResult << 8) + OSType(byte)
    }
}
