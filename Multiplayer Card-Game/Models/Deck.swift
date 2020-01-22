//
//  Deck.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 02/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

struct Deck {
    //MARK:- Property Variables
    
    //private(set) means that we can view the variable outside the class but can't set it's value
    private(set) var cards = [Card]()

    //MARK:- Initializers
    
    init() {
        for suit in Card.Suit.allSuits {
            for rank in Card.Rank.allRanks {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
    }
        
    //MARK:- Member Functions
    
    mutating func draw() -> Card? {
        if cards.count > 0{
            return cards.remove(at : cards.count.random)
        } else {
            return nil
        }
    }
    
    mutating func draw(card: Card) -> Card? {
        if let index = cards.firstIndex(of: card) {
            return cards.remove(at: index)
        } else {
            return nil
        }
    }
    
}
