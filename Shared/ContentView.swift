//
//  ContentView.swift
//  Shared
//
//  Created by foskvs on 03/11/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: USBPatcherDocument
    
    #if os(macOS)
    let leftOemWidth: CGFloat = 80
    let leftLengthWidth: CGFloat = 80
    #else
    let leftOemWidth: CGFloat = 50
    let leftLengthWidth: CGFloat = 70
    #endif
    let rightOemWidth: CGFloat = 160
    let rightLengthWidth: CGFloat = 50
    
    #if os(macOS)
    let portNameWidth: CGFloat = 40
    #else
    let portNameWidth: CGFloat = 50
    #endif
    #if os(macOS)
    let connectorPickerWidth: CGFloat = 200
    #else
    let connectorPickerWidth: CGFloat = 200
    #endif
    
    struct Connector: Identifiable {
        var name: String
        let value: Int
        var id = UUID()
    }
    
    let connectorTypes: [Connector] = [
        Connector(name: "0x00", value: 0),
        Connector(name: "0x01", value: 1),
        Connector(name: "0x02", value: 2),
        Connector(name: "0x03", value: 3),
        Connector(name: "0x08", value: 8),
        Connector(name: "0x09", value: 9),
        Connector(name: "0x0A", value: 10),
        Connector(name: "0xFF", value: 255),
        ]
    
    var body: some View {
        VStack {
            //TextEditor(text: $document.text)
            
            #if os(iOS)
            Button("Patch") {
                patch(doc: $document)
            }
            #endif
            List($document.portsInfo.ports) { $el in
                HStack {
                    Spacer()
                    Text(el.portName)
                        .frame(maxWidth: portNameWidth, alignment: .leading)
                    Picker("Connector Type", selection: $el.connectorType) {
                        ForEach(0..<connectorTypes.count) {
                            Text(connectorTypes[$0].name).tag(connectorTypes[$0].value)
                        }
                    }
                    .frame(maxWidth: connectorPickerWidth, alignment: .center)
                    Toggle("Enabled", isOn: $el.isEnabled)
                    Spacer()
                }
            }
            #if os(macOS)
            .listStyle(.bordered(alternatesRowBackgrounds:true))
            #endif
            HStack {
                VStack {
                    Text("Oem Table Id")
                        .frame(maxWidth: leftOemWidth + rightOemWidth, alignment: .center)
                        
                    HStack {
                        Text("String")
                            .frame(maxWidth: leftOemWidth, alignment: .leading)
                        Text(document.tableOemId)
                            .frame(maxWidth: rightOemWidth, alignment: .center)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("Hex")
                            .frame(maxWidth: leftOemWidth, alignment: .leading)
                        Text(document.tableOemIdHex)
                            .frame(maxWidth: rightOemWidth, alignment: .center)
                            .textSelection(.enabled)
                    }
                }
                #if os(macOS)
                Button("Patch") {
                    patch(doc: $document)
                }
                #endif
                VStack {
                    Text("Table Length")
                        .frame(maxWidth: leftLengthWidth + rightLengthWidth, alignment: .center)
                    HStack {
                        Text("Decimal")
                            .frame(maxWidth: leftLengthWidth, alignment: .leading)
                        Text(document.tableLength)
                            .frame(maxWidth: rightLengthWidth, alignment: .center)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("Hex")
                            .frame(maxWidth: leftLengthWidth, alignment: .leading)
                        Text(document.tableLengthHex)
                            .frame(maxWidth: rightLengthWidth, alignment: .center)
                            .textSelection(.enabled)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(USBPatcherDocument()))
    }
}
