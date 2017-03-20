//
//  Players.swift
//  IGNBonusApp
//
//  Created by Bradley French on 3/15/17.
//  Copyright © 2017 Bradley French. All rights reserved.
//

import UIKit


//I was thinking I was going to need more, but I only needed the hand, as most of the functionality is inside Tiles touches methods.
protocol Players {
    var hand:[Tile] {get set}
}

class AI: NSObject, Players {
    internal var hand: [Tile]
    var oldHand:Int = 0
    
    init(tiles:[Tile]) {
        self.hand = tiles
    }
}

class Human: NSObject, Players {
    internal var hand: [Tile]
    
    init(tiles:[Tile]) {
        self.hand = tiles
    }
}
