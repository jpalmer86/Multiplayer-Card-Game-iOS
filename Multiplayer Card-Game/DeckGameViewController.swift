//
//  DeckGameViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 16/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import UIKit

class DeckGameViewController: UIViewController {
    
    //MARK:- IBOUtlets
    
    @IBOutlet var startGameAndOptionsButton: UIButton! {
        didSet {
            startGameAndOptionsButton.addShadow()
            startGameAndOptionsButton.layer.cornerRadius = Constants.buttonCornerRadius
        }
    }
    @IBOutlet var gameStateLabel: UILabel!
    
    @IBOutlet var deckRightView: UIView!
    @IBOutlet var deckLeftView: UIView!
    
    @IBOutlet var emptyPlayerView: [UIView]! 
    
    @IBOutlet var player1Cards: [UIView]!
    @IBOutlet var player2Cards: [UIView]!
    @IBOutlet var player3Cards: [UIView]!
    @IBOutlet var player4Cards: [UIView]!
    
    @IBOutlet var playerNameLabel: [UILabel]!
    
    
    
    //MARK:- Property Variables
    private var cardViews: [[UIView]]!
    
    //MARK:- IBActions
    
    @IBAction func startGameOrOptions(_ sender: UIButton) {
    }
    
    
    //MARK:- Lifecycle Hooks

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardViews =  [player1Cards, player2Cards, player3Cards, player4Cards]

        addShadowToViews(viewArrays: [player1Cards, player2Cards, player3Cards, player4Cards, [deckRightView, deckLeftView]])
        
        addBorderToViews(viewArrays: [[deckRightView], emptyPlayerView])
        rotateViewArray(viewArrays: [[playerNameLabel[1], playerNameLabel[2], playerNameLabel[3], playerNameLabel[4]], emptyPlayerView, [player1Cards[0], player2Cards[0], player3Cards[0], player4Cards[0]]])
        
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Custom Methods
    
    private func rotateViewArray(viewArrays: [[UIView]]) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                if index == 1 || index == 3 {
                    let rotationDirection: CGFloat = index == 1 ? -1 : 1
                    viewArray[index].transform = .init(rotationAngle: rotationDirection * CGFloat.pi/2)
                }
            }
        }
    }
    
    private func addShadowToViews(viewArrays: [[UIView]]) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                viewArray[index].addShadow(offset: CGSize(width: 0, height: 0))
                viewArray[index].layer.cornerRadius = Constants.buttonCornerRadius
            }
        }
    }
    
    private func addBorderToViews(viewArrays: [[UIView]]) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                viewArray[index].addBorder(color: Constants.shadowColor)
            }
        }
    }
    
    private func setViewColor(views: [UIView], color: UIColor) {
        for viewToColor in views {
            viewToColor.backgroundColor = color
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
