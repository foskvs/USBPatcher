//
//  USBPatcherApp.swift
//  Shared
//
//  Created by Gabriele on 03/11/21.
//

import SwiftUI

@main
struct USBPatcherApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: USBPatcherDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
