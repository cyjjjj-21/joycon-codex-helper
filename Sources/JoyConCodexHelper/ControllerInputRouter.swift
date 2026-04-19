import Foundation
import GameController
import JoyConCodexCore

final class ControllerInputRouter {
    private let profile: Profile
    private let aliases: InputAliasRegistry
    private let actionDispatcher: ActionDispatcher
    private let logger: Logger

    init(
        profile: Profile,
        aliases: InputAliasRegistry,
        actionDispatcher: ActionDispatcher,
        logger: Logger
    ) {
        self.profile = profile
        self.aliases = aliases
        self.actionDispatcher = actionDispatcher
        self.logger = logger
    }

    func wire(controller: GCController) {
        let input = controller.physicalInputProfile

        for (physicalInput, action) in profile.physicalToAction {
            guard let targets = aliases.aliases[physicalInput] else {
                logger.error("Missing alias target for \(physicalInput)")
                continue
            }

            for target in targets {
                wire(target: target, action: action, on: input)
            }
        }
    }

    func unwire(controller: GCController) {
        let input = controller.physicalInputProfile

        for physicalInput in profile.physicalToAction.keys {
            guard let targets = aliases.aliases[physicalInput] else {
                continue
            }

            for target in targets {
                clear(target: target, on: input)
            }
        }
    }

    private func wire(target: InputAliasTarget, action: Action, on input: GCPhysicalInputProfile) {
        switch target.kind {
        case .hidButton:
            return
        case .button:
            guard let button = resolveButton(named: target.name, on: input) else {
                logger.info("Button alias \(target.name) is unavailable on this controller")
                return
            }

            button.pressedChangedHandler = { [weak self] _, _, pressed in
                self?.actionDispatcher.handle(action: action, isPressed: pressed)
            }
        case .dpadDirection:
            guard
                let direction = target.direction,
                let dpad = resolveDPad(named: target.name, on: input)
            else {
                logger.info("D-pad alias \(target.name) is unavailable on this controller")
                return
            }

            let axis = switch direction {
            case .up:
                dpad.up
            case .down:
                dpad.down
            case .left:
                dpad.left
            case .right:
                dpad.right
            }

            axis.pressedChangedHandler = { [weak self] _, _, pressed in
                self?.actionDispatcher.handle(action: action, isPressed: pressed)
            }
        }
    }

    private func resolveButton(named name: String, on input: GCPhysicalInputProfile) -> GCControllerButtonInput? {
        switch name {
        case "a":
            return input.buttons[GCInputButtonA]
        case "b":
            return input.buttons[GCInputButtonB]
        case "x":
            return input.buttons[GCInputButtonX]
        case "y":
            return input.buttons[GCInputButtonY]
        case "rightShoulder":
            return input.buttons[GCInputRightShoulder]
        case "rightTrigger":
            return input.buttons[GCInputRightTrigger]
        case "rightThumbstickButton":
            return input.buttons[GCInputRightThumbstickButton]
        case "home":
            return input.buttons[GCInputButtonHome]
        case "menu":
            return input.buttons[GCInputButtonMenu]
        case "options":
            return input.buttons[GCInputButtonOptions]
        default:
            return nil
        }
    }

    private func resolveDPad(named name: String, on input: GCPhysicalInputProfile) -> GCControllerDirectionPad? {
        switch name {
        case "directionPad":
            return input.dpads[GCInputDirectionPad]
        case "rightThumbstick":
            return input.dpads[GCInputRightThumbstick]
        case "leftThumbstick":
            return input.dpads[GCInputLeftThumbstick]
        default:
            return nil
        }
    }

    private func clear(target: InputAliasTarget, on input: GCPhysicalInputProfile) {
        switch target.kind {
        case .hidButton:
            return
        case .button:
            resolveButton(named: target.name, on: input)?.pressedChangedHandler = nil
        case .dpadDirection:
            guard
                let direction = target.direction,
                let dpad = resolveDPad(named: target.name, on: input)
            else {
                return
            }

            switch direction {
            case .up:
                dpad.up.pressedChangedHandler = nil
            case .down:
                dpad.down.pressedChangedHandler = nil
            case .left:
                dpad.left.pressedChangedHandler = nil
            case .right:
                dpad.right.pressedChangedHandler = nil
            }
        }
    }
}
