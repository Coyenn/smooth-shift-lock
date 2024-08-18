export interface SmoothShiftLockConfig {
    /**
     * Adds a button to toggle the shift lock for touchscreen devices.
     *
     * @default false
     */
    mobileSupport?: boolean;

    /**
     * If your character should rotate smoothly or not.
     *
     * @default true
     */
    smoothCharacterRotation?: boolean;

    /**
     * How quickly character rotates smoothly.
     *
     * @default 3
     */
    characterRotationSpeed?: number;

    /**
     * Camera transition spring damper, test it out to see what works for you.
     *
     * @default 0.7
     */
    transitionSpringDamper?: number;

    /**
     * How quickly locked camera moves to offset position.
     *
     * @default 10
     */
    cameraTransitionInSpeed?: number;

    /**
     * How quickly locked camera moves back from offset position.
     *
     * @default 14
     */
    cameraTransitionOutSpeed?: number;

    /**
     * Locked camera offset.
     *
     * @default Vector3.new(1.75, 0.25, 0)
     */
    lockedCameraOffset?: Vector3;

    /**
     * Locked mouse icon.
     *
     * @default "rbxasset://textures/MouseLockedCursor.png"
     */
    lockedMouseIcon?: string;

    /**
     * Shift lock keybinds.
     *
     * @default [Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift]
     */
    shiftLockKeybinds?: Enum.KeyCode[];
}

/**
 * The SmoothShiftLock class.
 */
export class SmoothShiftLock {
    constructor(config?: SmoothShiftLockConfig);

    /**
     * ShiftLock's enabled state.
     */
    enabled: boolean;

    /**
     * Enables shift lock.
     */
    enable(): void;

    /**
     * Disables shift lock.
     */
    disable(): void;

    /**
     * Returns ShiftLock's enabled state.
     *
     * @returns {boolean} ShiftLock's enabled state.
     */
    isEnabled(): boolean;

    /**
     * Toggles the ShiftLock, if Enable parameter is provided then ShiftLock will be toggled to it.
     *
     * @param {boolean} [enable] - If provided, ShiftLock will be toggled to it.
     */
    toggleShiftLock(enable?: boolean): void;
}
