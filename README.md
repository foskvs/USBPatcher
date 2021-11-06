[![Build Status](https://github.com/foskvs/USBPatcher/workflows/CI/badge.svg?branch=main)](https://github.com/foskvs/USBPatcher/actions)

# USBPatcher

Simple SwiftUI app that can to patch \_UPC methods to ACPI Source Language files.

If you use this software please cite this page.

## Usage

 - Open the decompiled SSDT with USBPatcher.
 - Fill the table with the proper values for `Connector Type` and select the checkboxes for the ports that you want to enable.
 - Click the `Patch` button.
 - Save the changes (optional, as autosave is enabled).
 - Compile the patched SSDT.

## Warning

The macOS target version should be at least macOS 12.0.

The iOS target version should be at least iOS 15.
Currently the app doesn't work on iOS.

# To-do list

 1. [ ] List only ports that have \_UPC defined in the SSDT.
 2. [ ] Open ACPI Machine Language binaries.
 3. [ ] Add the possibility to import the current configuration from the ACPI tables.
