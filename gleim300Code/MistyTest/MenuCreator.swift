//
//  MenuCreator.swift
//  MistyTest
//
//  Created by Jahresprojekt2017/18 on 08.04.18.
//  Copyright © 2018 Ivo Max Muellner. All rights reserved.
//

import Foundation

/*
 Creates the menu containing the commands for the portraits and
 the first audiofile that is played when the name of the person is recognized.
 */
class MenuCreator {

    public var topLevelMenu = GleimMenu()
    
    /*constructor*/
    init() {
        topLevelMenu = GleimMenu(name: "TopLevel")
//        var gleim = GleimMenu(name: "Gleim")
//        gleim.setSerialCommand(serialCommand: "1")
//        var ramler = GleimMenu(name: "Ramler")
    }
    
    public func getMenu() -> GleimMenu {
        return topLevelMenu
    }
}
