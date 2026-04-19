import Testing
@testable import JoyConCodexHelper

@Test
func connectedController_updatesStatusStore() {
    let store = StatusStore()

    store.updateConnection(controllerName: "Joy-Con (R)", isConnected: true)

    #expect(store.snapshot.connection == .connected(name: "Joy-Con (R)"))
    #expect(store.snapshot.battery == .unavailable)
}

@Test
func disconnect_clearsActiveControllerState() {
    let store = StatusStore()
    store.updateConnection(controllerName: "Joy-Con (R)", isConnected: true)
    store.updateBattery(level: 0.82, state: .discharging)

    store.updateConnection(controllerName: nil, isConnected: false)

    #expect(store.snapshot.connection == .disconnected)
    #expect(store.snapshot.battery == .unavailable)
}

@Test
func batteryUnavailable_isExplicitNotFakeZero() {
    let store = StatusStore()
    store.updateConnection(controllerName: "Joy-Con (R)", isConnected: true)

    store.updateBattery(level: nil, state: nil)

    #expect(store.snapshot.battery == .unavailable)
    #expect(!store.snapshot.lowBatteryWarning)
}

@Test
func lowBatteryWarning_appearsBelowThreshold() {
    let store = StatusStore()
    store.updateConnection(controllerName: "Joy-Con (R)", isConnected: true)

    store.updateBattery(level: 0.15, state: .discharging)

    #expect(store.snapshot.lowBatteryWarning)
}
