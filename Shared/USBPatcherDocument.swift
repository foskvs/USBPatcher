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
    static var amlBinary: UTType {
        UTType(importedAs: "org.acpica.aml")
    }
}

struct USBPatcherDocument: FileDocument {
    var text: String
    var tableLength: String
    var tableLengthHex: String
    var tableOemId: String
    var tableOemIdHex: String
    var portsList: [String]
    var tempPortsList: [String]
    var urlString: String

    var portsInfo: PortsInformation
    
    var isBinary: Bool
    var iaslPath: String
    var disassembledUrl: URL
    var newUrl: URL
    var FileName: String
    var disassembledName: NSMutableString
    var pwd: String
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
        tempPortsList = []
        urlString = ""
        
        isBinary = false
        iaslPath = ""
        disassembledUrl = URL(fileURLWithPath: "")
        newUrl = URL(fileURLWithPath: "")
        FileName = ""
        disassembledName = NSMutableString(string: FileName)
        pwd = ""
        
        parseText(text: text, length: &tableLength, lengthHex: &tableLengthHex, oemId: &tableOemId, oemIdHex: &tableOemIdHex, portsList: &tempPortsList)
        
        for port in tempPortsList {
            let textNS = NSMutableString(string: text)
            var result: Bool = false
            patchPort(textNS, port, false, 0xFF, false, &result)
            if (result == true) {
                portsList.append(port)
            }
        }
        
        self.portsInfo = PortsInformation(document: self)
        //self.portsInfo = PortsInformation()
    }

    static var readableContentTypes: [UTType] { [.dslText, .amlBinary] }

    init(configuration: ReadConfiguration) throws {
        //print(configuration.contentType)
        //print(configuration.file.fileAttributes)
        //print(String(data: configuration.file.regularFileContents!, encoding: .utf8))
        var string:String
        
        isBinary = false
        iaslPath = ""
        disassembledUrl = URL(fileURLWithPath: "")
        newUrl = URL(fileURLWithPath: "")
        FileName = ""
        disassembledName = NSMutableString(string: FileName)
        pwd = ""
        
        /*
        var result = runCommand(cmd: "/usr/bin/env", args: ["whoami"]).output
        print("whoami: ", result)
        result = runCommand(cmd: "/usr/bin/env", args: ["ls"]).output
        print("ls: ", result)*/
        /*
        result = runCommand(cmd: "/usr/bin/env", args: [iaslPath, "-v"]).output
        print("iasl: ", result)*/
        
        if (configuration.contentType == .dslText) {
            /*let result = runCommand(cmd: "/bin/zsh", args: ["--login", "-c", "iasl -v"]).output
            print(result)
            if (result != "") {
                print("Found iasl")
            }*/
            
            //macOS/macOS.entitlements
            guard let data = configuration.file.regularFileContents,
                  let str = String(data: data, encoding: .utf8)
            else {
                throw CocoaError(.fileReadCorruptFile)
            }
            string = str
        }
        else if (configuration.contentType == .amlBinary) {
            #if os(macOS)
            guard let iaslPathh = Bundle.main.path(forResource: "iasl", ofType: nil)
            else {
                print("iasl could not be found!")
                throw CocoaError(.serviceApplicationNotFound)
            }
            
            iaslPath = iaslPathh
            
            pwd = runCommand(cmd: "/usr/bin/env", args: ["pwd"]).output
            print("pwd: ", pwd)
            print(iaslPath)
            
            let data1 = configuration.file.regularFileContents
            let f = FileWrapper(regularFileWithContents: data1!)
            FileName = (configuration.file.filename ?? "")
            newUrl = URL(fileURLWithPath: pwd + "/" + FileName)
            print(newUrl)
            
            try! f.write(to: newUrl, options: .atomic, originalContentsURL: nil)
            //result = runCommand(cmd: "/usr/bin/env", args: ["echo -e", data1, ">", configuration.file.filename ?? ""]).output
            //print("ls: ", result)
            _ = runCommand(cmd: "/usr/bin/env", args: [iaslPath, "-d", FileName])
            /*
            result = runCommand(cmd: "/usr/bin/env", args: [iaslPath, "-d", FileName]).output
            print("ls: ", result)
            result = runCommand(cmd: "/usr/bin/env", args: ["ls"]).output
            print("ls: ", result)
            */
            
            disassembledName = NSMutableString(string: FileName)
            let regex = try NSRegularExpression(pattern: "\\..*$");
            regex.replaceMatches(in: disassembledName, options:.reportProgress, range: NSMakeRange(0, disassembledName.length), withTemplate: ".dsl");
            
            print(disassembledName)
            disassembledUrl = URL(fileURLWithPath: pwd + "/" + (disassembledName as String))
            
            let disassembledWrapper = try FileWrapper(url: disassembledUrl)
            
            
            guard let data = disassembledWrapper.regularFileContents,
                  let str = String(data: data, encoding: .utf8)
            else {
                throw CocoaError(.fileReadCorruptFile)
            }
            isBinary = true
            #else
            guard let data = configuration.file.regularFileContents,
                  let str = String(data: data, encoding: .utf8)
            else {
                throw CocoaError(.fileReadCorruptFile)
            }
            #endif
            string = str
        }
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
        tempPortsList = []
        urlString = ""
        
        parseText(text: text, length: &tableLength, lengthHex: &tableLengthHex, oemId: &tableOemId, oemIdHex: &tableOemIdHex, portsList: &tempPortsList)
        
        for port in tempPortsList {
            let textNS = NSMutableString(string: text)
            var result: Bool = false
            patchPort(textNS, port, false, 0xFF, false, &result)
            if (result == true) {
                portsList.append(port)
            }
        }
        
        self.portsInfo = PortsInformation(document: self)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data: Data
        if (isBinary == true) {
            #if os(macOS)
            let f = FileWrapper(regularFileWithContents: text.data(using: .utf8)!)
            try! f.write(to: disassembledUrl, options: .atomic, originalContentsURL: nil)
            
            // Compile the disassembled temporary file
            _ = runCommand(cmd: "/usr/bin/env", args: [iaslPath, "-f", disassembledName as String])
            
            let binaryWrapper = try FileWrapper(url: newUrl)
            
            data = binaryWrapper.regularFileContents!
            #else
            data = text.data(using: .utf8)!
            #endif
        }
        else {
            data = text.data(using: .utf8)!
        }
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
    if (doc.portsInfo.ports.count > 0) {
        for port in doc.portsInfo.ports {
            //print(port.portName.wrappedValue)
            let textNS = NSMutableString(string: doc.text.wrappedValue)
            var found: Bool = false
            patchPort(textNS, port.portName.wrappedValue, port.isEnabled.wrappedValue, port.connectorType.wrappedValue, true, &found)
            doc.text.wrappedValue = textNS as String
        }
    }
    //let textNS = NSMutableString(string: doc.text.wrappedValue)
    //patchPort(textNS, doc.portsInfo.ports[0].portName.wrappedValue, doc.portsInfo.ports[0].isEnabled.wrappedValue, doc.portsInfo.ports[0].connectorType.wrappedValue)
}

func initialiseUrl(document: Binding<USBPatcherDocument>, url: String) {
    document.urlString.wrappedValue = url
}
#if os(macOS)
func runCommand(cmd : String, args : [String]) -> (output: String, error: [String], exitCode: Int32) {
    
    var output : String = ""
    var error : [String] = []
    
    let task = Process()
    task.launchPath = cmd
    task.arguments = args
    
    let outpipe = Pipe()
    task.standardOutput = outpipe
    let errpipe = Pipe()
    task.standardError = errpipe
    
    task.launch()
    
    let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
    if var string = String(data: outdata, encoding: .utf8) {
        string = string.trimmingCharacters(in: .newlines)
        output = string//.components(separatedBy: "\n")
    }
    
    let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
    if var string = String(data: errdata, encoding: .utf8) {
        string = string.trimmingCharacters(in: .newlines)
        error = string.components(separatedBy: "\n")
    }
    
    task.waitUntilExit()
    let status = task.terminationStatus
    
    return (output, error, status)
}
#endif
