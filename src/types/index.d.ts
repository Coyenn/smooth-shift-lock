/**
 * The SmoothShiftLock class.
 */
export class SmoothShiftLock {
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
