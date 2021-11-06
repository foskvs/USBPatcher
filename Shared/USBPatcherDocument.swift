//
//  USBPatcherDocument.swift
//  Shared
//
//  Created by foskvs on 03/11/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var dslText: UTType {
        UTType(importedAs: "org.acpica.dsl")
    }
}

struct USBPatcherDocument: FileDocument {
    var text: String
    var tableLength: String
    var tableLengthHex: String
    var tableOemId: String
    var tableOemIdHex: String
    var portsList: [String]

    var portsInfo: PortsInformation
    //@State private var sortOrder = [KeyPathComparator(\Person.givenName)]
    /*
    init(text: String = "/*\n* Intel ACPI Component Architecture\n* AML/ASL+ Disassembler version 20210730 (64-bit version)\n* Copyright (c) 2000 - 2021 Intel Corporation\n*\n* Disassembling to symbolic ASL+ operators\n*\n* Disassembly of SSDT-4-xh_cfhd4.aml, Tue Nov  2 17:49:49 2021\n*\n* Original Table Header:\n*     Signature        \"SSDT\"\n*     Length           0x00002A07 (10759)\n*     Revision         0x02\n*     Checksum         0xFB\n*     OEM ID           \"INTEL\"\n*     OEM Table ID     \"xh_cfhd4\"\n*     OEM Revision     0x00000000 (0)\n*     Compiler ID      \"INTL\"\n*     Compiler Version 0x20160527 (538314023)\n*/") {
        self.text = text
        
        portsInfo = PortsInformation()
        
        tableLength = ""
        tableLengthHex = ""
        tableOemId = ""
        tableOemIdHex = ""
        portsList = []
        
        parseText(text: text, length: &tableLength, lengthHex: &tableLengthHex, oemId: &tableOemId, oemIdHex: &tableOemIdHex, portsList: &portsList)
        
        portsList = ["HS01", "HS02", "HS03"]
        
        self.portsInfo = PortsInformation(document: self)
        //self.portsInfo = PortsInformation()
    }*/
    
    init(text: String = "") {
        self.text = text
        
        portsInfo = PortsInformation()
        
        tableLength = ""
        tableLengthHex = ""
        tableOemId = ""
        tableOemIdHex = ""
        portsList = []
        
        parseText(text: text, length: &tableLength, lengthHex: &tableLengthHex, oemId: &tableOemId, oemIdHex: &tableOemIdHex, portsList: &portsList)
        
        self.portsInfo = PortsInformation(document: self)
        //self.portsInfo = PortsInformation()
    }

    static var readableContentTypes: [UTType] { [.dslText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
        portsInfo = PortsInformation()
        
        tableLength = ""
        tableLengthHex = ""
        tableOemId = ""
        tableOemIdHex = ""
        portsList = []
        
        parseText(text: text, length: &tableLength, lengthHex: &tableLengthHex, oemId: &tableOemId, oemIdHex: &tableOemIdHex, portsList: &portsList)
        
        self.portsInfo = PortsInformation(document: self)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}

struct PortsInformation {
    struct Port: Identifiable {
        var portName: String
        var connectorType: Int
        var isEnabled: Bool
        var id = UUID()
    }
    
    init() {
        ports = [
            //Port(portName: "", connectorType: 0, isEnabled: true),
        ]
    }
    
    init(document: USBPatcherDocument) {
        self.ports = []
        //print(document.portsList)
        for el in document.portsList {
            self.ports.append(Port(portName: el, connectorType: 255, isEnabled: false))
        }
        //print(ports)
    }
    
    var ports: [Port]
}

func parseText(text: String, length: inout String, lengthHex: inout String, oemId: inout String, oemIdHex: inout String, portsList: inout [String]) {
    
    
    let lengthNS = NSMutableString(string: length)
    let lengthHexNS = NSMutableString(string: lengthHex)
    let oemIdNS = NSMutableString(string: oemId)
    let oemIdHexNS = NSMutableString(string: oemIdHex)
    let portsListNS = NSMutableArray(array: portsList)
    
    cParseText(text, lengthNS, lengthHexNS, oemIdNS, oemIdHexNS, portsListNS)
    
    //print("L", lengthNS, " a", lengthHexNS)
    length = lengthNS as String
    lengthHex = lengthHexNS as String
    oemId = oemIdNS as String
    oemIdHex = oemIdHexNS as String
    portsList = portsListNS as! [String]
    
}

func patch(doc: Binding<USBPatcherDocument>) {
    for port in doc.portsInfo.ports {
        //print(port)
        let textNS = NSMutableString(string: doc.text.wrappedValue)
        patchPort(textNS, port.portName.wrappedValue, port.isEnabled.wrappedValue, port.connectorType.wrappedValue)
        doc.text.wrappedValue = textNS as String
    }
    //let textNS = NSMutableString(string: doc.text.wrappedValue)
    //patchPort(textNS, doc.portsInfo.ports[0].portName.wrappedValue, doc.portsInfo.ports[0].isEnabled.wrappedValue, doc.portsInfo.ports[0].connectorType.wrappedValue)
}
