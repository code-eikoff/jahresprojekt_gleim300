//
//  XmlMenuReader.swift
//  MistyTest
//
//  Created by Jahresprojekt2017/18 on 04.05.18.
//  Copyright © 2018 Ivo Max Muellner. All rights reserved.
//

import Foundation

/*
 Parser
 */
class XmlMenuReader: NSObject, XMLParserDelegate {
    
    private var topLevelMenu = GleimMenu()
    private var currentMenu = GleimMenu()
    private var parentMenu = GleimMenu()
    
    private var currentElement = "nil"
    
    private var menuCreator = MenuCreator()
    
    public var complete = false
    
    
    /*constructor*/
//    init(menuCreator: MenuCreator){
//        super.init()
//        self.menuCreator = menuCreator
//        if let path = Bundle.main.url(forResource: "GleimMenuStructure", withExtension: "xml") {
//            if let parser = XMLParser(contentsOf: path) {
//                print("Parser started!")
//                parser.delegate = self
//                parser.parse()
//            } else {
//                print("Parser didn't start!")
//            }
//        }
//    }
    /*constructor*/
    init(menuCreator: MenuCreator){
        super.init()
        self.menuCreator = menuCreator
        
        let fileURL = URL(fileURLWithPath: NSHomeDirectory()+"/Desktop/Gleim300Assets/GleimMenuStructure.xml")
        
        if let parser = XMLParser(contentsOf: fileURL) {
            print("Parser started!")
            parser.delegate = self
            parser.parse()
        } else {
            print("Parser didn't start!")
        }
    }
    
    
    
    /*
     Sets current menu to topLevelMenu and starts parsing.
     */
    func parserDidStartDocument(_ parser: XMLParser) {
        print("reading started!")
        currentMenu = topLevelMenu
    }
    /*
     Sets "new" topLevelMenu (the one containing the corret data) as topLevelMenu, if the parsing ends.
     */
    func parserDidEndDocument(_ parser: XMLParser) {
        print("finished reading!")
        complete = true
        menuCreator.topLevelMenu = topLevelMenu
    }
    
    /*
     Adds the data correctly to the menu.
     */
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "nil" { return };
        
        if currentElement == "VoiceCommand" {
            currentMenu.addCommand(command: string)
        }
        else if currentElement == "SerialCommand" {
            currentMenu.setSerialCommand(serialCommand: string)
        }
        else if currentElement == "AudioPath" {
            currentMenu.setAudioFilePath(path: string)
        }
        else if currentElement == "ReturnCommand" {
            currentMenu.addReturnCommand(command: string)
        }
        else if currentElement == "isTopic" {
            if(string=="true"){
                currentMenu.setIsTopic(topic: true)
            }
            
        }
        
//        print("found characters: <"+string+"> for current element: "+currentElement)
    }
    
    /*
     Adds the new elements to the menu.
     */
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
//        print("Endelement: "+elementName)
        if elementName == "GleimMenu" {
//            print("added <"+currentMenu.getName()+"> to parent <"+parentMenu.getName()+">" )
            currentMenu = parentMenu
            parentMenu = GleimMenu.getParentMenu(childOfParent: currentMenu, searchMenu: topLevelMenu)
        }
        currentElement = "nil" //just the string element not the current GleimMenu
    }
    
    /*
     Gets each element sets the menupath for it.
     */
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        if currentElement == "GleimMenu" {
            if attributeDict["Name"] != "topLevel" {
                let subMenu = GleimMenu()
                parentMenu = currentMenu
                currentMenu = subMenu
                parentMenu.addSubMenuElement(element: currentMenu)
            }
            currentMenu.setName(name: attributeDict["Name"]!)
//            print("GLEIMMENU NAME: "+attributeDict["Name"]!)
        }
    }
}
