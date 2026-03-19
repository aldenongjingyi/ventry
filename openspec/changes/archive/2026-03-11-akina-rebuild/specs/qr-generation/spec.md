# QR Code Generation

## Overview

QR codes are generated client-side and encode only the item's UUID. They are displayed within the app for on-screen scanning and can be printed via the system print dialog. The format is designed to be forward-compatible with industrial barcode labels.

## Requirements

1. QR codes are generated client-side using the `qr_flutter` package (or equivalent).
2. The encoded data is the item's `qr_code` UUID field as a plain string (no URL wrapping, no prefix).
3. QR codes use error correction level M (medium, ~15% recovery).
4. The QR code is displayed on the item detail screen at a fixed size suitable for on-screen viewing.
5. Tapping the QR code on the item detail screen opens a full-screen view optimized for scanning by another device (white background, maximum size, screen brightness increased).
6. The full-screen QR view displays the item name and item number above or below the code for human reference.
7. A "Print" button is available on the full-screen QR view. It triggers the system print dialog with a print-optimized layout.
8. The print layout includes: QR code, item name, item number, and organisation name, formatted to fit common label sizes (62mm x 29mm as default).
9. No server-side QR generation or storage is required.
10. The QR code widget accepts any string, making it forward-compatible with non-UUID barcode values if the encoding scheme changes in future versions.

## Data Model

No new tables. Uses `items.qr_code` (UUID) as the encoded payload.

## Behavior

- The QR code is regenerated from the UUID each time the widget builds; it is not cached as an image.
- If the item's `qr_code` field is null or empty (should not happen in normal flow), display a placeholder with an error message.
- Full-screen QR view prevents the screen from sleeping (wake lock) while open.
- The print layout uses black-on-white only for maximum scan reliability.
- Brightness is restored to the user's previous setting when the full-screen view is dismissed.
- The full-screen view includes a close button and supports back-gesture/swipe to dismiss.
