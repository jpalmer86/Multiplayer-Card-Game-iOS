//
//  UIView+border.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 16/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation
import UIKit

//MARK:- UIView extensions

extension UIView {
    
    //MARK:- Helper Variables
    
    struct sizeRatio {
        static let cornerFontSizeToBoundsHeight : CGFloat = 0.085
        static let cornerRadiusToBoundsHeight : CGFloat = 0.15
        static let cornerOffsetToCornerRadius : CGFloat = 0.33
        static let faceCardImageSizeToBoundSize : CGFloat = 0.75
    }
    
    var cornerRadius : CGFloat {
        return bounds.size.height * sizeRatio.cornerRadiusToBoundsHeight
    }
    
    var cornerOffset : CGFloat {
        return cornerRadius * sizeRatio.cornerOffsetToCornerRadius
    }
    
    var cornerFontSize:  CGFloat {
        return bounds.size.height * sizeRatio.cornerFontSizeToBoundsHeight
    }
    
    //MARK:- Add Border extension
    
    func addBorder(color: UIColor, borderWidth: CGFloat = Constants.borderWidth, cornerRadius: CGFloat? = nil) {

        var correctCornerRadius = cornerRadius
        if correctCornerRadius == nil {
            correctCornerRadius = self.cornerRadius
        }
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: correctCornerRadius!)
        roundedRect.addClip()
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = roundedRect.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = self.bounds
        self.layer.addSublayer(borderLayer)
        self.layer.cornerRadius = correctCornerRadius!
    }
    
    //MARK:- Add Shadow
    
    func addShadow(color: UIColor = Constants.shadowColor, opacity: Float = Constants.shadowOpacity, radius: CGFloat = Constants.shadowRadius, offset: CGSize = Constants.shadowOffset) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
    }
    
    //// Adds a rounded corner around the view
    func addRoundCorner() {
        layer.cornerRadius = cornerRadius
    }
}
