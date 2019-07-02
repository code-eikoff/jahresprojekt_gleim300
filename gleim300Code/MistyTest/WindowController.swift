//
//  WindowController.swift
//  MistyTest
//
//  Created by Jahresprojekt2017/18/19 on 16.01.19.
//  Copyright © 2019 Eiko Eickhoff. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
    
    var dele  = ViewController()
    
    override func windowDidLoad() {
//        self.window!.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true
//        self.window!.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)!.isHidden = true
        window?.level = .floating   //immer im Vordergrund
     
    }

    
    func windowWillClose(_ notification: Notification) {
        print("Window will close")
        dele.Light_Audio_Out()
    }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        print("Window should close")
        return true
    }
    func windowDidChangeScreen(_ notification: Notification) {
        print("Window did change screen")
    }
    
}
