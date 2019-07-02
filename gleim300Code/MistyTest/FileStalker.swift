//
//  FileStalker.swift
//  MistyTest
//
//  Created by Jahresprojekt2017/18 on 19.04.18.
//  Copyright © 2018 Ivo Max Muellner. All rights reserved.
//

import Foundation

protocol FileStalkerDelegate {
    func fileContentChanged(fileSerialCommand serialCommand: String, fileAudio audiofile: String)
}

/*
 Reads the file containing the data.
 Is needed for the backend.
 */
class FileStalker  {
    
    var delegate : FileStalkerDelegate?
    var lastReadText = "nil"
    var timer = Timer()
    var timerInterval = 0.1 //sek
    var filename = ""
    
    /*constructor*/
    init(timerInterval: Double, filename: String) {
        self.timerInterval = timerInterval
        self.filename = filename
    }
    
    /*
     Sets a timer.
     After a certain time calls the method for reading the file.
     */
    func startStalking(){
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(readFromFile), userInfo: nil, repeats: true)
    }
    
    /*
     Stops reading the file.
     */
    func stopStalking(){
        timer.invalidate()
    }
    
    /*
     Reads the file and looks for changes.
     Changes the data if the data in the file was changed.
     */
    @objc private func readFromFile() {
        let fileURL = URL(fileURLWithPath: filename)
        //reading
        do {
            let currentText = try String(contentsOf: fileURL, encoding: .utf8)
            if currentText.contains("unread"){
                if lastReadText != "nil" && lastReadText != currentText {
                    let splitCommand = currentText.split(separator: ";")
                    delegate?.fileContentChanged(fileSerialCommand: String(splitCommand[0]), fileAudio: String(splitCommand[1]))
                    
                    //write "read" to file
                    try (String(splitCommand[0])+";"+String(splitCommand[1])+";"+"read").write(to: fileURL, atomically: false, encoding: .utf8)
                } else {
                    let splitCommand = currentText.split(separator: ";")
                    let readCommand = String(splitCommand[0])+";"+String(splitCommand[1])+";"+"read"
                    try readCommand.write(to: fileURL, atomically: false, encoding: .utf8)
                    lastReadText = readCommand
                    
                }
            }
        }
        catch {
            print("reading or writing failed")
        }
        
    }
}

