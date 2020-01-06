//
//  GameTableViewCell.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    //MARK:- IBOutlets
    @IBOutlet var gameNameLabel: UILabel! {
        didSet {
            gameNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: gameNameLabel.font.pointSize)
        }
    }
    @IBOutlet var gameDescriptionLabel: UILabel!
    @IBOutlet var playerDescriptionLabel: UILabel!{
        didSet {
            playerDescriptionLabel.font = UIFont(name:"HelveticaNeue-Bold", size: playerDescriptionLabel.font.pointSize)
        }
    }
    @IBOutlet var gameImageView: UIImageView!
    
    //MARK:- Property variables
    var game: Game! {
        didSet {
            gameNameLabel?.text = game.name
            
            gameImageView?.image = game.image
            
            playerDescriptionLabel?.text = game.playerDescription
            gameDescriptionLabel?.text = game.gameDescription
            
            setNeedsDisplay()
        }
    }
    
    //MARK:- Lifecycle Hooks
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }
    
}
