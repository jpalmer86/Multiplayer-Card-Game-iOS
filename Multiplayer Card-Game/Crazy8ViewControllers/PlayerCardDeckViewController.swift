//
//  PlayerCardDeckViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 19/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import UIKit

class PlayerCardDeckViewController: UIViewController {

    //MARK:- IBOutlets
    
    @IBOutlet var cardViews: [CardView]!
    @IBOutlet var cardStackView: UIStackView!
    
    //MARK:- Property Variables
    
    private let gameManager = GameManager.shared
    var cards: [Card]? {
        didSet {
            updateUI()
        }
    }
    var indexToPlay = 0 //// This should be set by the gameManager
    private let colorKey: [Int: String] = [
        0: Constants.Colors.Crazy8.green.rawValue,
        1: Constants.Colors.Crazy8.blue.rawValue,
        2: Constants.Colors.Crazy8.pink.rawValue,
        3: Constants.Colors.Crazy8.yellow.rawValue,
        4: Constants.Colors.Crazy8.red.rawValue,
    ]
    
    //MARK:- Lifecycle Hooks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager.cardsDelegate = self
                
        if let index = gameManager.players.firstIndex(of: GameService.shared.getPeerID()) {
            cards = gameManager.cardsForPlayer[index]
        }
        
        for cardView in cardViews {
            cardView.transform = .init(rotationAngle: -CGFloat.pi/2)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
            cardView.addGestureRecognizer(tapGesture)
        }
    }
    
    //MARK:- ViewController Methods
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Custom Methods
    
    private func updateUI() {
        DispatchQueue.main.async { [unowned self] in
            guard let cards = self.cards else { return }
            for cardView in self.cardViews {
                cardView.alpha = 0
                cardView.isUserInteractionEnabled = false
                cardView.addShadow()
                cardView.addBorder(color: Constants.Colors.color[self.colorKey[self.indexToPlay]!]!)
            }
            for (index,card) in cards.enumerated() {
                self.cardViews[index].rank = card.rank.order
                self.cardViews[index].suit = card.suit.description
                self.cardViews[index].isFaceUp = true
                self.cardViews[index].alpha = 1
                self.cardViews[index].isUserInteractionEnabled = true
            }
        }
    }
    
    @objc func selectCard(_ sender: UITapGestureRecognizer? = nil) {
        if let senderView = sender?.view, let cardView = senderView as? CardView, let index = cardViews.firstIndex(of: cardView) {
            gameManager.swapCard(player: gameService.getPeerID(),index: index)
        }
    }
}

//MARK:- GameCard Manager Delegate Methods

extension PlayerCardDeckViewController: GameCardManagerDelegate {
    func cardsSwapped(updatedCards: [Card]) {
        cards = updatedCards
    }
}
