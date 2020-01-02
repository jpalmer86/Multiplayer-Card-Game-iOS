//
//  Card.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 02/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

struct Card : CustomStringConvertible {
    
    //MARK:- Property Variables
    var suit: Suit
    var rank: Rank
    
    var description: String{ return "\(rank) \(suit)"}
    
    //swift generates an initilizer for the structs automatically
    
    
    //MARK:- enum Suit
    enum Suit : String, CustomStringConvertible {
        
        var description: String {
            return self.rawValue
        }
        
        case hearts = "♥️"
        case spades = "♠️"
        case diamonds = "♦️"
        case clubs = "♣️"
        
        static var allSuits = [Suit.hearts , .spades, .diamonds , .clubs]
    }
    
    //MARK:- enum Rank
    enum Rank: CustomStringConvertible {
        
        public var description: String {
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
        
        static var allRanks : [Rank] {
            
            var all = [Rank.ace]
            
            for pips in 2...10{
                all.append(Rank.numeric(pips))
            }
            all+=[Rank.face("J"),Rank.face("Q"),Rank.face("K")]
            return all
        }
    }
}
