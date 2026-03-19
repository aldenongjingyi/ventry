# HID Barcode Scanner Support

## Overview

External Bluetooth barcode scanners operating in HID (Human Interface Device) keyboard-wedge mode are supported as an alternative to the built-in camera scanner. The external scanner sends keystrokes representing the scanned barcode value, terminated by an Enter key. The app detects this input and feeds it into the same relocation flow as camera scans.

## Requirements

1. A hidden, always-focused text field captures HID keyboard input when the scanner screen is active.
2. The app detects barcode input by recognizing a burst of characters (inter-keystroke interval under 50ms) terminated by an Enter key.
3. On detecting a complete barcode input, the captured string is trimmed and treated as a QR code value (UUID).
4. The captured UUID is routed through the same post-scan flow as camera scans, respecting the active scanner mode (Quick, Smart, or Manual).
5. The user can toggle between camera mode and HID mode via a button on the scanner screen.
6. When HID mode is active, the camera preview is hidden and replaced with a listening indicator (e.g., "Waiting for scanner input..." with a pulsing icon).
7. When camera mode is active, HID input is still passively captured so that an external scan while the camera is open still works.
8. The scanner mode preference (camera vs HID as default) is stored in local user preferences.

## Data Model

No new tables or fields. The HID scanner produces the same UUID string that the camera scanner produces.

## Behavior

- The hidden text field must reclaim focus if the user taps elsewhere on the scanner screen. A `FocusNode` with `requestFocus()` on every frame or on tap is used.
- If the captured string is not a valid UUID, display an "Invalid barcode" error and discard the input.
- If the inter-keystroke interval exceeds 50ms mid-sequence, the partial input is discarded (it was likely manual typing, not a scanner).
- Multiple rapid scans are queued: the first scan opens the relocation flow; subsequent scans are held until the current flow completes or is dismissed.
- HID mode works on both iOS and Android. On iOS, the external keyboard may trigger the software keyboard to hide, which is acceptable.
- The Enter key (both `\n` and `\r`) is treated as the terminator. The terminator character itself is not included in the captured value.
- If Bluetooth is off or the external scanner is not paired, HID mode still activates (it simply waits for input). No Bluetooth pairing UI is provided by the app; the user pairs via system settings.
