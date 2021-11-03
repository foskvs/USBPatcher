//
//  ContentView.swift
//  Shared
//
//  Created by Gabriele on 03/11/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: USBPatcherDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(USBPatcherDocument()))
    }
}
