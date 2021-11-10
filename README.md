[![Build Status](https://github.com/foskvs/USBPatcher/workflows/Build/badge.svg?branch=main)](https://github.com/foskvs/USBPatcher/actions)

# USBPatcher

Simple SwiftUI app that can patch \_UPC methods to ACPI Source Language files.

If you use this software please cite this page.

The app includes `iasl` as a bundle inside `Contents/Resources` (it is used to compile/decompile AML files).
You can update it to the latest version by downloading it from [here](https://acpica.org/downloads).

Source code is [here](https://github.com/acpica/acpica).

## Usage

You can open ACPI Machine Language binaries directly, so there is no need to recompile the SSDT after you patch it.

 - Open the decompiled SSDT with USBPatcher (optional).
 - Fill the table with the proper values for `Connector Type` and select the checkboxes for the ports that you want to enable.
 - Click the `Patch` button.
   - Warning: `Patch` applies the patch to all the ports, so make sure you disable any ports you don't need.
 - Save the changes (optional, as autosave is enabled).
 - Compile the patched SSDT (not needed if opening directly an AML file).

## Supported configurations

Currently only SSDTs with with ports declared on an external table (e.g. DSDT) are supported.

Both `Name (_UPC, ...` and `Method (_UPC, ...` are supported.

## Warning

I am not responsible for corrupt files.

The macOS target version should be at least macOS 12.0.

The iOS target version should be at least iOS 15.
Currently the app doesn't work on iOS.

## To-do list

 1. [X] Support tables with \_UPC defined as `Name`.
 2. [ ] Support ports that are defined in the same table of \_UPC (e.g. DSDTs).
 3. [X] List only ports that have \_UPC defined in the SSDT.
 4. [X] Open ACPI Machine Language binaries.
 5. [ ] Add the possibility to import the current configuration from the ACPI tables.
