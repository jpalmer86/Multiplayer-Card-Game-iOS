//
//  PlayerCardsViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 03/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import UIKit

class PlayerCardsViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet var cardViews: [CardView]!
    
    //MARK:- Property Variables
    private let gameManager = GameManager.shared
    var cards: [Card]? {
        didSet {
            updateUI()
        }
    }
    
    //MARK:- Lifecycle Hooks
    override func viewDidLoad() {
        gameManager.cardsDelegate = self
        super.viewDidLoad()
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        if let index = gameManager.players.firstIndex(of: GameService.shared.getPeerID()) {
            cards = gameManager.cardsForPlayer[index]
        }
        
        for cardView in cardViews {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
            cardView.addGestureRecognizer(tapGesture)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeLeft)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        AppUtility.lockOrientation(.all)
    }
    
    //MARK:- ViewController Methods
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
      }
    
    //MARK:- Custom Methods
    private func updateUI() {
        guard let cards = cards else { return }
        for cardView in cardViews {
            cardView.isHidden = true
            cardView.isUserInteractionEnabled = false
        }
        for (index,card) in cards.enumerated() {
            cardViews[index].rank = card.rank.order
            cardViews[index].suit = card.suit.description
            cardViews[index].isFaceUp = true
            cardViews[index].isHidden = false
            cardViews[index].isUserInteractionEnabled = true
        }
    }
    
    @objc func selectCard(_ sender: UITapGestureRecognizer? = nil) {
        if let senderView = sender?.view, let cardView = senderView as? CardView, let index = cardViews.firstIndex(of: cardView) {
            gameManager.swapCardWithFirst(player: gameService.getPeerID(),index: index)
        }
    }
}

//MARK:- GameCard Manager Delegate Methods
extension PlayerCardsViewController: GameCardManagerDelegate {
    func cardsSwapped(updatedCards: [Card]) {
        cards = updatedCards
    }
}
