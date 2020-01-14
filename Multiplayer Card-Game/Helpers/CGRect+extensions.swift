//
//  CGRect+extensions.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 03/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import UIKit
//MARK:- CGRect extensions

extension CGRect {
    var leftHalf : CGRect {
        return CGRect(x: minX ,y: minY, width: width/2, height: height)
    }
    var rightHalf : CGRect{
        return CGRect(x: midX ,y: minY, width: width/2, height: height)
    }
    func inset(by size :CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(by size : CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale : CGFloat) -> CGRect {
        let newWidth = width*scale
        let newHeight = height*scale
        
        //insetBy returns a rect that has same centre point but different size ....
        //        a +ve sign of the dx means decrease in size ,and -ve means an increase in size
        return insetBy(dx: (width - newWidth)/2, dy: (height - newHeight)/2)
    }
    
}
