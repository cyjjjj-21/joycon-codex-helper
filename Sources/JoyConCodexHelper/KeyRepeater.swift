import Foundation

protocol KeyRepeating: AnyObject {
    func start(key: String, modifiers: [String]) throws
    func stop(key: String, modifiers: [String]) throws
    func stopAll()
}

final class TimerKeyRepeater: NSObject, KeyRepeating {
    private let keyboardEmitter: KeyboardEventSending
    private let initialDelay: TimeInterval
    private let interval: TimeInterval
    private var timers: [String: Timer] = [:]
    private var repeatState: [String: RepeatRequest] = [:]

    init(
        keyboardEmitter: KeyboardEventSending,
        initialDelay: TimeInterval = 0.35,
        interval: TimeInterval = 0.055
    ) {
        self.keyboardEmitter = keyboardEmitter
        self.initialDelay = initialDelay
        self.interval = interval
        super.init()
    }

    func start(key: String, modifiers: [String]) throws {
        let repeatID = Self.repeatID(key: key, modifiers: modifiers)
        guard timers[repeatID] == nil else {
            return
        }

        try keyboardEmitter.tap(key: key, modifiers: modifiers)
        repeatState[repeatID] = RepeatRequest(key: key, modifiers: modifiers)
        let timer = Timer.scheduledTimer(
            timeInterval: initialDelay,
            target: self,
            selector: #selector(initialDelayFired(_:)),
            userInfo: repeatID,
            repeats: false
        )
        timers[repeatID] = timer
    }

    func stop(key: String, modifiers: [String]) throws {
        let repeatID = Self.repeatID(key: key, modifiers: modifiers)
        timers.removeValue(forKey: repeatID)?.invalidate()
        repeatState.removeValue(forKey: repeatID)
    }

    func stopAll() {
        for timer in timers.values {
            timer.invalidate()
        }
        timers.removeAll()
        repeatState.removeAll()
    }

    @objc
    private func initialDelayFired(_ timer: Timer) {
        guard
            let repeatID = timer.userInfo as? String,
            timers[repeatID] != nil,
            repeatState[repeatID] != nil
        else {
            return
        }

        let timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(repeatTimerFired(_:)),
            userInfo: repeatID,
            repeats: true
        )
        timers[repeatID] = timer
    }

    @objc
    private func repeatTimerFired(_ timer: Timer) {
        guard
            let repeatID = timer.userInfo as? String,
            let request = repeatState[repeatID]
        else {
            return
        }

        do {
            try keyboardEmitter.tap(key: request.key, modifiers: request.modifiers)
        } catch {
            stopAll()
        }
    }

    private static func repeatID(key: String, modifiers: [String]) -> String {
        ([key] + modifiers).joined(separator: "+")
    }
}

private struct RepeatRequest {
    let key: String
    let modifiers: [String]
}
