//
//  USBPatcherApp.swift
//  Shared
//
//  Created by foskvs on 03/11/21.
//

import SwiftUI

@main
struct USBPatcherApp: App {
    var body: some Scene {
        var previousFileURL: String = ""
        DocumentGroup(newDocument: USBPatcherDocument()) { file in
            ContentView(document: file.$document, url: file.fileURL?.path ?? "")
                .onAppear() {
                    previousFileURL = file.fileURL?.path ?? ""
                    initialiseUrl(document: file.$document, url: previousFileURL)
                }
        }
    }
}
