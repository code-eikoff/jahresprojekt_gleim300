//
//  SerialHandler.swift
//  MistyTest
//
//  Created by Madita Lange on 25.11.17.
//  Copyright © 2017 Mona Holtmann. All rights reserved.
//

import Foundation
/*
class SerialHandler : NSObject, ORSSerialPortDelegate {
    let standardInputFileHandle = NSFileHandle.fileHandleWithStandardInput()
    var serialPort: ORSSerialPort?
    
    func runProcessingInput() {
        setbuf(stdout, nil)
        
        standardInputFileHandle.readabilityHandler = { (fileHandle: NSFileHandle!) in
            let data = fileHandle.availableData
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.handleUserInput(data)
            })
        }
        
        self.serialPort = ORSSerialPort(path: "/dev/cu.Repleo-PL2303-00401414") // please adjust to your handle
        self.serialPort?.baudRate = 9600
        self.serialPort?.delegate = self
        serialPort?.open()
        
        NSRunLoop.currentRunLoop().run() // loop
    }
    
    
    func handleUserInput(dataFromUser: NSData) {
        if let string = NSString(data: dataFromUser, encoding: NSUTF8StringEncoding) as? String {
            
            if string.lowercaseString.hasPrefix("exit") ||
                string.lowercaseString.hasPrefix("quit") {
                println("Quitting...")
                exit(EXIT_SUCCESS)
            }
            self.serialPort?.sendData(dataFromUser)
        }
    }
    
    // ORSSerialPortDelegate
    
    func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
        if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
            print("\(string)")
        }
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        self.serialPort = nil
    }
    
    func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
        println("Serial port (\(serialPort)) encountered error: \(error)")
    }
    
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        println("Serial port \(serialPort) was opened")
    }
}


println("Starting serial test program")
println("To quit type: 'exit' or 'quit'")
SerialHandler().runProcessingInput()

*/
