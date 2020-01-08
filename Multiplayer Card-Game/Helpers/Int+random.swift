//
//  Int+random.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 03/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

//MARK:- Int Extension
extension Int {
    var random : Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
