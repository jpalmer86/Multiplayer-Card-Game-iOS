//
//  ViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import UIKit

class GameTableViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    //MARK:- Member Variables
    var games = [Game]() {
        didSet {
            tableView.setNeedsLayout()
            tableView.setNeedsDisplay()
        }
    }
    
    //MARK:- Lifecycle Hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCell()
        title = "Home"
        games = Constants.getAllGamesInfo()
        // Do any additional setup after loading the view.
    }
    //MARK:- Custom Methods
    private func registerTableViewCell() {
        let tableViewCell = UINib(nibName: "GameTableViewCell", bundle: nil)
        self.tableView.register(tableViewCell, forCellReuseIdentifier: "GameTableViewCell")
    }
}

//MARK:- UITableViewDelegate Methods
extension GameTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: segueIdentifier, sender: tableView.cellForRow(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 256
    }
}

//MARK:- UITableViewDataSource Methods
extension GameTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell") as? GameTableViewCell {
            print(games[indexPath.item].image)
            cell.game = games[indexPath.item]
            return cell
        }
        return GameTableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
