//
//  Card.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 02/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

struct Card : CustomStringConvertible, Comparable {
    
    //MARK:- Property Variables
    
    var suit: Suit
    var rank: Rank
    
    var description: String{ return "\(rank) \(suit)"}
    
    //MARK:- Enum Suit
    
    enum Suit : String, CustomStringConvertible, Equatable {

        var description: String {
            return self.rawValue
        }
        
        case hearts = "♥️"
        case spades = "♠️"
        case diamonds = "♦️"
        case clubs = "♣️"
        
        static var allSuits = [Suit.hearts , .spades, .diamonds , .clubs]
    }
    
    //MARK:- Enum Rank
    
    enum Rank: CustomStringConvertible, Comparable {
        
        var description: String {
            switch self {
            case .ace: return "A"
            case .numeric(let pips) : return "\(pips)"
            case .face(let kind) : return kind
            }
        }
        
        case ace
        case numeric(Int)
        case face(String)
        
        var order : Int {
            switch self {
            case .ace: return 1
            case .numeric(let pips) : return pips
            case .face(let kind) where kind == "J" : return 11
            case .face(let kind) where kind == "Q" : return 12
            case .face(let kind) where kind == "K" : return 13
            default : return 0
            }
        }
        
        static func < (lhs: Card.Rank, rhs: Card.Rank) -> Bool {
            if lhs.order != 1 && rhs.order != 1 {
                return lhs.order < rhs.order
            } else if lhs.order != 1 && rhs.order == 1 {
                return true
            } else {
                return false
            }
        }
        
        static var allRanks : [Rank] {
            
            var all = [Rank.ace]
            
            for pips in 2...10 {
                all.append(Rank.numeric(pips))
            }
            all += [Rank.face("J"),Rank.face("Q"),Rank.face("K")]
            return all
        }
        
        static func orderOf(rank: String) -> Int {
            if let numeric = Int(rank) {
                return numeric
            } else {
                if rank == "A" {
                    return 1
                } else if rank == "J" {
                    return 11
                } else if rank == "Q" {
                    return 12
                } else if rank == "K" {
                    return 13
                } else {
                    return 0
                }
            }
        }
    }
    
    static func < (lhs: Card, rhs: Card) -> Bool {
        return lhs.rank < rhs.rank
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
}
