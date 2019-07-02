//
//  GleimMenuList.swift
//  MistyTest
//
//  Created by Jahresprojekt2017/18 on 08.04.18.
//  Copyright © 2018 Mona Holtmann. All rights reserved.
//

import Foundation

class GleimMenu{
    
    private var subMenuList = [GleimMenu]()
    private var name = ""
    private var audioFilePath = ""
    private var commandList = NSArray()
    
    init(name: String, subMenuList: Array<GleimMenu>, audioFilePath: String, commandList: NSArray){
        self.name=name
        self.subMenuList=subMenuList
        self.audioFilePath=audioFilePath
        self.commandList=commandList
    }
    
    public func getSubMenuList() -> Array<GleimMenu> {
        return subMenuList
    }
    
    public func getName() -> String {
        return name
    }
    
    public func getAudioFilePath() -> String {
        return audioFilePath
    }
    
    public func getCommandList() -> NSArray {
        return commandList
    }
    
    
}
