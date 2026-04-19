import Foundation
import IOKit.hid

final class RawHIDInputRouter {
    private let actionMap: HIDButtonActionMap
    private let actionDispatcher: ActionDispatcher
    private let logger: Logger
    private var manager: IOHIDManager?

    init(actionMap: HIDButtonActionMap, actionDispatcher: ActionDispatcher, logger: Logger) {
        self.actionMap = actionMap
        self.actionDispatcher = actionDispatcher
        self.logger = logger
    }

    func start() {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let matching: [String: Any] = [
            kIOHIDVendorIDKey as String: 0x057e,
            kIOHIDProductIDKey as String: 0x2007
        ]
        IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)

        let context = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterDeviceMatchingCallback(manager, rawHIDDeviceMatched, context)
        IOHIDManagerRegisterInputValueCallback(manager, rawHIDValueReceived, context)
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)

        let result = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        guard result == kIOReturnSuccess else {
            logger.error("Failed to open raw HID input router: \(result)")
            IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
            return
        }

        self.manager = manager
        logger.info("Raw HID input router started")
    }

    func stop() {
        guard let manager else {
            return
        }

        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        self.manager = nil
    }

    fileprivate func handleDeviceMatched(_ device: IOHIDDevice) {
        let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String
        logger.info("Raw HID matched \(product ?? "Joy-Con")")
    }

    fileprivate func handleValue(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let usagePage = Int(IOHIDElementGetUsagePage(element))
        let usage = Int(IOHIDElementGetUsage(element))
        guard let action = actionMap.action(forUsagePage: usagePage, usage: usage) else {
            return
        }

        let isPressed = IOHIDValueGetIntegerValue(value) != 0
        actionDispatcher.handle(action: action, isPressed: isPressed)
    }
}

private let rawHIDDeviceMatched: IOHIDDeviceCallback = { context, _, _, device in
    guard let context else {
        return
    }

    Unmanaged<RawHIDInputRouter>
        .fromOpaque(context)
        .takeUnretainedValue()
        .handleDeviceMatched(device)
}

private let rawHIDValueReceived: IOHIDValueCallback = { context, _, _, value in
    guard let context else {
        return
    }

    Unmanaged<RawHIDInputRouter>
        .fromOpaque(context)
        .takeUnretainedValue()
        .handleValue(value)
}
