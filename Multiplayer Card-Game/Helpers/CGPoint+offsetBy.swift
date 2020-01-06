//
//  CGPoint+offsetBy.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 03/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import UIKit
//MARK:- CGPoint extension
extension CGPoint {
    func offsetBy(dx : CGFloat, dy : CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
