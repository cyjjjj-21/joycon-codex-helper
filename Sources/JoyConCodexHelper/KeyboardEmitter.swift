import Carbon.HIToolbox
import Foundation

protocol KeyboardEventSending: AnyObject {
    func tap(key: String, modifiers: [String]) throws
    func beginHold(key: String, modifiers: [String]) throws
    func endHold(key: String, modifiers: [String]) throws
    func releaseAllHolds() throws
}

protocol KeyboardEventPosting: AnyObject {
    func post(keyCode: CGKeyCode, keyDown: Bool, flags: CGEventFlags) throws
}

enum KeyboardEmitterError: Error, Equatable {
    case unsupportedKey(String)
    case eventCreationFailed(String)
}

final class CGEventKeyboardEmitter: KeyboardEventSending {
    private let eventPoster: KeyboardEventPosting
    private var activeHolds: [String: KeyShortcut] = [:]

    init(eventPoster: KeyboardEventPosting = CGEventKeyboardEventPoster()) {
        self.eventPoster = eventPoster
    }

    func tap(key: String, modifiers: [String]) throws {
        let shortcut = try KeyShortcut(key: key, modifiers: modifiers)
        try postKeyDownChord(shortcut)
        try postKeyUpChord(shortcut)
    }

    func beginHold(key: String, modifiers: [String]) throws {
        let shortcut = try KeyShortcut(key: key, modifiers: modifiers)
        let holdID = shortcut.id
        guard activeHolds[holdID] == nil else {
            return
        }

        do {
            try postKeyDownChord(shortcut)
            activeHolds[holdID] = shortcut
        } catch {
            try? postKeyUpChord(shortcut)
            throw error
        }
    }

    func endHold(key: String, modifiers: [String]) throws {
        let shortcut = try KeyShortcut(key: key, modifiers: modifiers)
        let holdID = shortcut.id
        guard let activeHold = activeHolds[holdID] else {
            return
        }

        do {
            try postKeyUpChord(activeHold)
            activeHolds.removeValue(forKey: holdID)
        } catch {
            activeHolds[holdID] = activeHold
            throw error
        }
    }

    func releaseAllHolds() throws {
        var firstError: Error?
        for (holdID, shortcut) in activeHolds {
            do {
                try postKeyUpChord(shortcut)
                activeHolds.removeValue(forKey: holdID)
            } catch {
                if firstError == nil {
                    firstError = error
                }
            }
        }

        if let firstError {
            throw firstError
        }
    }

    private func postKeyDownChord(_ shortcut: KeyShortcut) throws {
        for modifier in shortcut.modifierSequence {
            try eventPoster.post(keyCode: modifier.keyCode, keyDown: true, flags: modifier.flags)
        }

        try eventPoster.post(keyCode: shortcut.keyCode, keyDown: true, flags: shortcut.flags)
    }

    private func postKeyUpChord(_ shortcut: KeyShortcut) throws {
        try eventPoster.post(keyCode: shortcut.keyCode, keyDown: false, flags: shortcut.flags)

        for modifier in shortcut.modifierSequence.reversed() {
            try eventPoster.post(keyCode: modifier.keyCode, keyDown: false, flags: modifier.flags)
        }
    }
}

final class CGEventKeyboardEventPoster: KeyboardEventPosting {
    func post(keyCode: CGKeyCode, keyDown: Bool, flags: CGEventFlags) throws {
        let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: keyDown)
        guard let event else {
            throw KeyboardEmitterError.eventCreationFailed(String(keyCode))
        }

        event.flags = flags
        event.post(tap: .cghidEventTap)
    }
}

private struct KeyShortcut {
    let key: String
    let keyCode: CGKeyCode
    let flags: CGEventFlags
    let modifierSequence: [KeyModifier]
    let id: String

    init(key: String, modifiers: [String]) throws {
        let resolvedModifiers = try modifiers.map(KeyModifier.init(name:))
        self.key = key
        self.keyCode = try KeyShortcut.keyCode(for: key)
        self.flags = resolvedModifiers.reduce(into: []) { partialResult, modifier in
            partialResult.insert(modifier.flags)
        }
        self.modifierSequence = resolvedModifiers
        self.id = ([key] + modifiers).joined(separator: "+")
    }

    private static func keyCode(for key: String) throws -> CGKeyCode {
        switch key {
        case "UpArrow":
            return CGKeyCode(kVK_UpArrow)
        case "DownArrow":
            return CGKeyCode(kVK_DownArrow)
        case "LeftArrow":
            return CGKeyCode(kVK_LeftArrow)
        case "RightArrow":
            return CGKeyCode(kVK_RightArrow)
        case "Return":
            return CGKeyCode(kVK_Return)
        case "Backspace":
            return CGKeyCode(kVK_Delete)
        case "Tab":
            return CGKeyCode(kVK_Tab)
        case "M":
            return CGKeyCode(kVK_ANSI_M)
        case "F18":
            return CGKeyCode(kVK_F18)
        default:
            throw KeyboardEmitterError.unsupportedKey(key)
        }
    }
}

private struct KeyModifier {
    let label: String
    let keyCode: CGKeyCode
    let flags: CGEventFlags

    init(name: String) throws {
        switch name {
        case "Shift":
            label = name
            keyCode = CGKeyCode(kVK_Shift)
            flags = .maskShift
        case "Control":
            label = name
            keyCode = CGKeyCode(kVK_Control)
            flags = .maskControl
        case "Option":
            label = name
            keyCode = CGKeyCode(kVK_Option)
            flags = .maskAlternate
        case "Command":
            label = name
            keyCode = CGKeyCode(kVK_Command)
            flags = .maskCommand
        default:
            throw KeyboardEmitterError.unsupportedKey(name)
        }
    }
}
