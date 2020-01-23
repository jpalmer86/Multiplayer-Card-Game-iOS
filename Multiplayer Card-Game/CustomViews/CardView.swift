//
//  CardView.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 02/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CardView: UIView {
    
    ////    setneedsLayout calls the layoutSubviews method to add new views to existing views
    ////    setNeedDisplay is called to redraw the view
    
    //MARK:- PlayingCardView member variables
    
    @IBInspectable
    var rank : Int = 11 {didSet{setNeedsLayout() ; setNeedsDisplay()}}
    
    @IBInspectable
    var suit :String = "♥️" {didSet{setNeedsLayout() ; setNeedsDisplay()}}
    
    @IBInspectable
    var isFaceUp :Bool = true {didSet{setNeedsLayout() ; setNeedsDisplay()}}
    
    var faceCardScale : CGFloat = sizeRatio.faceCardImageSizeToBoundSize {
        didSet{
            setNeedsDisplay()
        }
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString+"\n"+suit, cornerFontSize)
    }
    
    private lazy var upperLeftCornerLabel = createCornerLabel()
    
    private lazy var lowerRightCornerLabel = createCornerLabel()
    
    
    //MARK:- PlayingCardView Member Functions
    
    ////    called by setNeedsLayout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureCornerLabels(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
    
        configureCornerLabels(lowerRightCornerLabel)
        ////       CGAffineTransform.identity contains only three methods scale translate and  rotate
        ////        uiview has a var called trranform that is used to transform the view
        lowerRightCornerLabel.transform = CGAffineTransform.identity
        .translatedBy(x: lowerRightCornerLabel.frame.width, y: lowerRightCornerLabel.frame.height)
        .rotated(by: CGFloat.pi)
        
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
        
    }
    
    ////    This func is called whenever there is a change in preferences
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    ////   A bezier path that is created by the above class cannot stand on its own. It needs a Core Graphics context where it can be rendered to. There are three ways to get a context like that:
    ////    1.To use a CGContext context.
    ////    2.To subclass the UIView class which you want to draw the custom shape to, and use its draw(_:) method provided by default. The context needed        is provided automatically then.
    ////    3.To create special layers called CAShapeLayer objects.
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        ////        will act as the parent view for the next views
        ////        clip the view that is not in the bounds of this view
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            if let faceCardImage = UIImage(named: rankString+suit,in: Bundle(for: self.classForCoder),compatibleWith: traitCollection){
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else {
                drawpips()
            }
        } else {
            if let faceCardBackImage = UIImage(named: "cardback",in: Bundle(for: self.classForCoder),compatibleWith: traitCollection){
                faceCardBackImage.draw(in: bounds)
            }
        }
        
    }
    
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer :UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            faceCardScale*=recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    //MARK:- Private Methods
    
    private func centeredAttributedString(_ string : String , _ fontSize : CGFloat) -> NSAttributedString {
        ////  UIFont.preferredFont(forTextStyle: .body) vs UIFontMetrics(forTextStyle: .body)
        ////        uifontmetrics was introduced on ios 11 to make the default font scale upto the new font given or scaled(via settings) by the user
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return NSAttributedString(string: string, attributes: [.paragraphStyle : paragraphStyle , .font : font])
    }

    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        ////        0 means any number of lines
        label.numberOfLines = 0
        ////        adds label as a subview in our uiview
        addSubview(label)
        return label
    }
    
    private func configureCornerLabels(_ label : UILabel) {
        label.attributedText = cornerString
        
        label.frame.size = CGSize.zero
        //// zero = wrap content epand as much as the text is,take more space if needed by the text
        label.sizeToFit()
        label.isHidden = !isFaceUp
    }
    
    private func drawpips() {
        
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]
        
        func createPipString(thatFits pipRect : CGRect)-> NSAttributedString {
            
            ////            reduce the whole array into a single value
            ////            the method given by the reduced closure is used to calculate the single value
            ////            for e.g. reduce(initialValue : 0){ return $0+$1} will return the sum of elements of the array
            ////          initialValue is the value inside the closure when the first element is calculated by the closure
            ////            this closure is returned repeatedly
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0){max($1.count, $0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0){max($1.max() ?? 0, $0)})
            let verticalPipRowSpacing = pipRect.size.height/maxVerticalPipCount
            
            let attemptedPipString = centeredAttributedString(suit, verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing/(attemptedPipString.size().height/verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, probablyOkayPipStringFontSize)
            
            if probablyOkayPipString.size().width > pipRect.size.width/maxHorizontalPipCount{
                return centeredAttributedString(suit, probablyOkayPipStringFontSize/(probablyOkayPipString.size().width/(pipRect.size.width/maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height/2)
            
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height/CGFloat(pipsPerRow.count)
            
            ////            we are resizing our rectangle equal to the width of pipRect and a height of the string
            ////            and then we are translating that rectangle on every pipRow
            pipRect.size.height = pipString.size().height
            //// shifting the origin to every row
            pipRect.origin.y += (pipRowSpacing - pipRect.height)/2
            for pipsCount in pipsPerRow {
                switch pipsCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default :
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
   
}

//MARK:- PlayingCardView extensions

extension CardView {

    private var rankString : String {
        switch rank {
        case 1 : return "A"
        case 2...10 :return String(rank)
        case 11 : return "J"
        case 12 : return "Q"
        case 13 : return "K"
        default : return "?"
        }
    }
    
}
