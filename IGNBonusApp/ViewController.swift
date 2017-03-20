//
//  ViewController.swift
//  IGNBonusApp
//
//  Created by Bradley French on 3/15/17.
//  Copyright © 2017 Bradley French. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var players:[Players] = []
    var board:Gameboard!
    var tiles:Tiles!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //This just creates the board, the player, and the tiles
    func createGame() {
        self.board = Gameboard(frame: self.view.frame, controller: self)
        self.view.addSubview(self.board)
        
        self.tiles = Tiles(board: board)
        self.board.tiles = self.tiles
        
        let humanPlayer = Human(tiles: self.tiles.getTile(count: 6))
        let ai = AI(tiles: self.tiles.getTile(count: 6))
        self.players.append(humanPlayer)
        self.board.player.append(humanPlayer); self.board.player.append(ai)
        self.board.createTiles(count: 6)
    }
}

