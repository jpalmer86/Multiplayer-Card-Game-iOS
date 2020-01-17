//
//  DeckGameViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 16/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import UIKit

//MARK:- Enum CardState

enum CardsState {
    case unselected
    case selected
    case taken
}

class DeckGameViewController: UIViewController {
    
    //MARK:- IBOUtlets
    
    @IBOutlet var startGameAndOptionsButton: UIButton! {
        didSet {
            startGameAndOptionsButton.addShadow()
            startGameAndOptionsButton.layer.cornerRadius = Constants.buttonCornerRadius
        }
    }
    @IBOutlet var gameStateLabel: UILabel!
    
    @IBOutlet var stackViewDeck: UIStackView!
    @IBOutlet var deckRightView: UIView!
    @IBOutlet var deckLeftView: UIView!

    @IBOutlet var player1StackView: UIStackView!
    @IBOutlet var player2StackView: UIStackView!
    @IBOutlet var player3StackView: UIStackView!
    @IBOutlet var player4StackView: UIStackView!
    
    @IBOutlet var emptyPlayerView: [UIView]!
    
    @IBOutlet var player1Cards: [UIView]!
    @IBOutlet var player2Cards: [UIView]!
    @IBOutlet var player3Cards: [UIView]!
    @IBOutlet var player4Cards: [UIView]!
    
    @IBOutlet var playerNameLabel: [UILabel]!
    
    
    
    //MARK:- Property Variables
    var isHost: Bool = true ////  this should be set by the previous viewcontroller
    var indexToPlay = 0 //// This should be set by the gameManager
    
    private var cardViews: [[UIView]]!

    private let colorKey: [Int: String] = [
        0: Constants.Colors.Crazy8.green.rawValue,
        1: Constants.Colors.Crazy8.blue.rawValue,
        2: Constants.Colors.Crazy8.pink.rawValue,
        3: Constants.Colors.Crazy8.yellow.rawValue,
        4: Constants.Colors.Crazy8.red.rawValue,
    ]
    private let unSelectColor = Constants.Colors.color[Constants.Colors.Crazy8.lightGrey.rawValue]!
    private let takenColor = Constants.Colors.color[Constants.Colors.Crazy8.darkGrey.rawValue]!
    private var cardViewsState: [CardsState]! {
        didSet {
            for index in 0..<cardViewsState.count {
                switch cardViewsState[index] {
                case .unselected:
                    if index == 0 {
                        setViewColor(viewsArray: [cardViews[index][0]], color: unSelectColor)
                        addBorderToViews(viewArrays: [[cardViews[index][1]]], color: UIColor.white)
                    } else {
                        setViewColor(viewsArray: cardViews[index], color: unSelectColor)
                    }
                    playerNameLabel[index].textColor = unSelectColor
                case .selected:
                    let color = Constants.Colors.color[colorKey[indexToPlay]!]!
                    if index == 0 {
                        setViewColor(viewsArray: [cardViews[index][0]], color: color)
                        addBorderToViews(viewArrays: [[cardViews[index][1]]], color: color)
                    } else {
                        setViewColor(viewsArray: cardViews[index], color: color)
                    }
                    playerNameLabel[index].textColor = Constants.Colors.color[colorKey[indexToPlay]!]!
                case .taken:
                    if index == 0 {
                        setViewColor(viewsArray: [cardViews[index][0]], color: takenColor)
                        addBorderToViews(viewArrays: [[cardViews[index][1]]], color: takenColor)
                    } else {
                        setViewColor(viewsArray: cardViews[index], color: takenColor)
                    }
                    playerNameLabel[index].textColor = takenColor
                }
            }
        }
    }

    
    //MARK:- IBActions
    
    @IBAction func startGameOrOptions(_ sender: UIButton) {
        print("Start Game")
    }
    
    
    //MARK:- Lifecycle Hooks

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startGameAndOptionsButton.backgroundColor = Constants.Colors.color[colorKey[indexToPlay]!]!
        gameStateLabel.textColor = Constants.Colors.color[colorKey[indexToPlay]!]!
        
        cardViews =  [[deckLeftView, deckRightView], player1Cards, player2Cards, player3Cards, player4Cards]
        
        cardViewsState = [.unselected, .unselected, .unselected, .unselected, .unselected]

        addShadowToViews(viewArrays: [[deckRightView, deckLeftView]])
        
        addShadowToViews(viewArrays: [player1Cards, player2Cards, player3Cards, player4Cards], offset: Constants.shadowOffsetCard)
        
        addBorderToViews(viewArrays: [emptyPlayerView])
        rotateViewArray(viewArrays: [[playerNameLabel[1], playerNameLabel[2], playerNameLabel[3], playerNameLabel[4]], emptyPlayerView, [player1StackView, player2StackView, player3StackView, player4StackView]])
        
        for label in playerNameLabel {
            label.textColor = unSelectColor
        }
        
        if isHost {
            stackViewDeck.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectDeck(_:)))
            stackViewDeck.addGestureRecognizer(tapRecognizer)
            for deckView in cardViews[0] {
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectDeck(_:)))
                deckView.addGestureRecognizer(tapRecognizer)
            }
        }

        for playerIndex in 1..<cardViews.count {
            for cardIndex in 0..<cardViews[playerIndex].count {
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedPlayer(_:)))
                cardViews[playerIndex][cardIndex].addGestureRecognizer(tapRecognizer)
            }
        }
    }
    
    //MARK:- Custom Methods
    
    @objc func selectedPlayer(_ sender: UIGestureRecognizer) {
        if let tappedView = sender.view, let playerIndex = getPlayerIndexOf(cardView: tappedView) {
            for index in 0..<cardViewsState.count {
                if cardViewsState[index] == .selected {
                    cardViewsState[index] = .unselected
                }
            }
            cardViewsState[playerIndex] = .selected
        }
    }
    
    @objc func selectDeck(_ sender: UIGestureRecognizer) {
        for index in 0..<cardViewsState.count {
            if cardViewsState[index] == .selected {
                cardViewsState[index] = .unselected
            }
        }
        cardViewsState[0] = .selected
    }
    
    private func getPlayerIndexOf(cardView: UIView) -> Int? {
        for playerIndex in 1..<5 {
            if let _ = cardViews[playerIndex].firstIndex(of: cardView) {
                return playerIndex
            }
        }
        return nil
    }
    
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
    
    private func addShadowToViews(viewArrays: [[UIView]], offset: CGSize = CGSize(width: 0, height: 0)) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                viewArray[index].addShadow(offset: offset)
                viewArray[index].layer.cornerRadius = Constants.buttonCornerRadius
            }
        }
    }
    
    private func addBorderToViews(viewArrays: [[UIView]], color: UIColor = Constants.shadowColor) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                viewArray[index].addBorder(color: color)
            }
        }
    }
    
    private func setViewColor(viewsArray: [UIView], color: UIColor) {
        for viewToColor in viewsArray {
            viewToColor.backgroundColor = color
        }
    }
    
    private func disableUserInteraction(viewArrays: [[UIView]]) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                viewArray[index].isUserInteractionEnabled = false
            }
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

//MARK:- Gesture Recognizer Delegate Methods

//extension DeckGameViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}
