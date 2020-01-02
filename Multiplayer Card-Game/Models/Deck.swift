//
//  Deck.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 02/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

struct Deck {
    init() {
        for suit in Card.Suit.allSuits{
            for rank in Card.Rank.allRanks{
                cards.append(Card(suit: suit, rank: rank))
            }
        }
    }
    
    
    //MARK:- variable cards
    //private(set) means that we can view the variable outside the class but cant set the value of it
    private(set) var cards = [Card]()

    
    //MARK:- function to draw cards
    mutating func draw() -> Card? {
        if cards.count > 0{
            return cards.remove(at : cards.count.random)
        }else{
            return nil
        }
    }
    
}

//MARK:- Int extension
extension Int {
    var random : Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
