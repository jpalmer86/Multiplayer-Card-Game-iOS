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
    @IBOutlet var deckStackView: UIStackView!
    @IBOutlet var leftDeckView: CardView!
    @IBOutlet var rightDeckView: UIView! {
        didSet {
            rightDeckTopCardView = CardView(frame: rightDeckView.frame)
        }
    }
    
    //MARK:- Property Variables
    
    private let gameManager = GameManager.shared
    private var selectedColor: UIColor! = UIColor.white
    private var isDeck = false {
        didSet {
            updateDeck()
        }
    }
    private var isHost = false
    
    private var rightDeckTopCardView = CardView()
    var cards: [Card]? {
        didSet {
            updateUI()
        }
    }
    private var enableInteraction = false
    
    //MARK:- Lifecycle Hooks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager.cardsDelegate = self
                
        if let index = gameManager.players.firstIndex(of: GameService.shared.getPeerID()) {
            cards = gameManager.cardsForPlayer[index]
        }
        
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
        
        for cardView in cardViews {
            cardView.addShadow()
            cardView.transform = .init(rotationAngle: -CGFloat.pi/2)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
            cardView.addGestureRecognizer(tapGesture)
            
            let dragInteraction = UIDragInteraction(delegate: self)
            dragInteraction.isEnabled = true
            cardView.addInteraction(dragInteraction)
        }
        
        deckStackView.transform = .init(rotationAngle: -CGFloat.pi/2)
        leftDeckView.addShadow()
        rightDeckView.addShadow()
        rightDeckView.addBorder(color: self.selectedColor)
        rightDeckTopCardView.isHidden = true
        rightDeckView.addSubview(rightDeckTopCardView)
        
        updateDeck()
    }
    
    //MARK:- ViewController Methods
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Custom Methods
    
    @objc func selectCard(_ sender: UITapGestureRecognizer? = nil) {
        if let senderView = sender?.view, let cardView = senderView as? CardView, let index = cardViews.firstIndex(of: cardView) {
            // gameManager.swapCard(player: gameService.getPeerID(),index: index)
        }
    }
    
    func setDeck(deck: Bool) {
        isDeck = deck
    }
    
    func setColor(color: UIColor) {
        selectedColor = color
    }
    
    func enablePlayer(enable: Bool) {
        enableInteraction = enable
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let cardViews = self.cardViews else { return }
            for cardView in cardViews {
                cardView.isUserInteractionEnabled = enable
            }
        }
    }
    
    //MARK:- Private Methods
    
    private func updateUI() {
        DispatchQueue.main.async { [unowned self] in
            guard let cards = self.cards else { return }
            if self.isDeck {
                if let cards = self.cards, cards.count > 0 {
                    let card = cards.last!
                    self.rightDeckTopCardView.rank = card.rank.order
                    self.rightDeckTopCardView.suit = card.suit.description
                    self.rightDeckTopCardView.isHidden = false
                }
            } else {
                for cardView in self.cardViews {
                    cardView.alpha = 0
                    cardView.isFaceUp = true
                    cardView.addShadow()
                    cardView.addBorder(color: self.selectedColor)
                    cardView.isUserInteractionEnabled = false
                }
                for (index,card) in cards.enumerated() {
                    self.cardViews[index].rank = card.rank.order
                    self.cardViews[index].suit = card.suit.description
                    self.cardViews[index].isFaceUp = true
                    self.cardViews[index].alpha = 1
                    self.cardViews[index].isUserInteractionEnabled = self.enableInteraction
                }
            }
        }
    }
    
    private func updateDeck() {
        deckStackView?.isHidden = !isDeck
        cardStackView?.isHidden = isDeck
    }
}

//MARK:- GameCard Manager Delegate Methods

extension PlayerCardDeckViewController: GameCardManagerDelegate {
    func cardsSwapped(updatedCards: [Card], deck: Bool) {
        cards = updatedCards
    }
}

//MARK:- UIDragInteraction Delegate Methods

extension PlayerCardDeckViewController: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let rank = cardViews[0].rank
        let suit = cardViews[0].suit
        let object = "\(rank)-\(suit)"
        let stringProvider = NSItemProvider(object: object as NSString)
        return [UIDragItem(itemProvider: stringProvider)]
    }
}

//MARK:- UIDropInteraction Delegate Methods

extension PlayerCardDeckViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        gameManager.throwCardInCenter(player: gameManager.playersConnected[0], card: gameManager.cardsForPlayer[0][0])
    }
}
