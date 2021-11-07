[![Build Status](https://github.com/foskvs/USBPatcher/workflows/Build/badge.svg?branch=main)](https://github.com/foskvs/USBPatcher/actions)

# USBPatcher

Simple SwiftUI app that can to patch \_UPC methods to ACPI Source Language files.

If you use this software please cite this page.

## Usage

 - Open the decompiled SSDT with USBPatcher.
 - Fill the table with the proper values for `Connector Type` and select the checkboxes for the ports that you want to enable.
 - Click the `Patch` button.
   - Warning: `Patch` applies the patch to all the ports, so make sure you disable any ports you don't need.
 - Save the changes (optional, as autosave is enabled).
 - Compile the patched SSDT.

## Supported configurations

Currently only SSDTs with `Method (_UPC, ...` and with ports declared on an external table (e.g. DSDT) are supported.

## Warning

The macOS target version should be at least macOS 12.0.

The iOS target version should be at least iOS 15.
Currently the app doesn't work on iOS.

## To-do list

 1. [ ] Support tables with \_UPC defined as `Name`.
 1. [ ] Support ports that are defined in the same table of \_UPC (e.g. DSDTs).
 1. [ ] List only ports that have \_UPC defined in the SSDT.
 2. [ ] Open ACPI Machine Language binaries.
 3. [ ] Add the possibility to import the current configuration from the ACPI tables.
