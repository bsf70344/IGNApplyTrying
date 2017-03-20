//
//  Tiles.swift
//  IGNBonusApp
//
//  Created by Bradley French on 3/15/17.
//  Copyright © 2017 Bradley French. All rights reserved.
//

import UIKit

//This is the Tiles class so I can keep up with the different types of Tiles and the number of Tiles
class Tiles: NSObject {
    
    var shapes:[String] = ["Square", "8-sided Star", "Circle", "diamond-Star", "4-Leaf Clover", "Diamond"]
    var colors:[UIColor] = [.orange, .purple, .yellow, .red, .green, .blue]
    var numberOfShapesAndColors:[[Int]] = []
    var count = 108
    let board:Gameboard!
    
    init(board:Gameboard) {
        self.board = board
        for i in 0 ..< 6 {
            numberOfShapesAndColors.append([])
            for _ in 0 ..< 6 {
                numberOfShapesAndColors[i].append(3)
            }
        }
        print(numberOfShapesAndColors)
        super.init()
    }
    
    //Method to get tiles, if they are just trading tiles out, then
    func getTile(count:Int, trade:Bool = false, tradeTiles:[Tile]? = nil) -> [Tile] {
        var tiles:[Tile] = []
        let realCount = (self.count >= 6) ? count : self.count
        for _ in 0 ..< realCount {
            //Random tiles
            var shapeNumber = Int(arc4random_uniform(UInt32(numberOfShapesAndColors.count)))
            var colorNumber = Int(arc4random_uniform(UInt32(numberOfShapesAndColors[shapeNumber].count)))
            while(numberOfShapesAndColors[shapeNumber][colorNumber] == 0) {
                //If its 0, its not there, we need a new one.
                shapeNumber = Int(arc4random_uniform(UInt32(numberOfShapesAndColors.count)))
                colorNumber = Int(arc4random_uniform(UInt32(numberOfShapesAndColors[shapeNumber].count)))
            }
            if(numberOfShapesAndColors[shapeNumber][colorNumber] != 0) {
                tiles.append(Tile(shape: shapes[shapeNumber], color: colors[colorNumber], board: self.board))
            }
        }
        //If we are not trading, dont decrement the count
        if(!trade) {
            self.count -= realCount
        }
            
        //We need to add back the tiles we are trading in
        else {
            if(tradeTiles != nil) {
                for tile in tradeTiles! {
                    let shapeIndex = shapes.index(of: tile.shape)
                    let colorIndex = colors.index(of: tile.color)
                    numberOfShapesAndColors[shapeIndex!][colorIndex!] += 1
                }
            }
        }
        return tiles
    }
}

class Tile: UIView {
    
    //Shape and color to indicate tile
    var shape:String!
    var color:UIColor!
    
    //Board object to move
    var board:Gameboard!
    
    //I need a copy to move around
    var copyTile:Tile!
    
    //I create the original location
    var copyTileOffSet:CGPoint!
    
    //Need to know where it is at
    var moving:Bool = false
    var startLocation:CGFloat! = 0
    
    //Initialize
    convenience init(shape:String, color:UIColor, board:Gameboard) {
        self.init()
        self.shape = shape
        self.color = color
        self.board = board
    }
    
    //This draws the tile
    override func draw(_ rect: CGRect) {
        print(self.shape)
        let fillColor = self.color
        fillColor!.setFill()
        
        let path = createBezierPath()
        path.fill()
        path.stroke()
    }
    
    //This moves the tile accordingly and sets up variables for use later.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self.board)
        startLocation = location.x+location.y
        copyTileOffSet = touches.first?.location(in: self)
        if(self.board.playersBoard.frame.contains(location)) {
            moving = true
            self.isHidden = true
            copyTile = self.copy() as! Tile
            self.copyTile.frame = CGRect(x: self.frame.minX, y: self.frame.minY+board.scrollView.frame.height, width: self.frame.width, height: self.frame.height)
            copyTile.layer.borderColor = UIColor.orange.cgColor
            copyTile.layer.borderWidth = 1
            board.addSubview(copyTile)
        }
    }
    
    //I just move the tile around the board
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(moving) {
            let location = touches.first!.location(in: board)
            self.copyTile.frame = CGRect(x: location.x-copyTileOffSet.x, y: location.y-copyTileOffSet.y, width: self.frame.width, height: self.frame.height)
        }
    }
   
    //Depending on where they drop the tile, it will allow them and place it on the board nicely for them, or it won't allow it and the piece will go back to the players hand.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(moving) {
            let location = touches.first!.location(in: self.board)
            if(self.board.brownBoardView.frame.contains(location) && !self.board.playersBoard.frame.contains(location)) {
                let gridlocation = touches.first!.location(in: self.board.brownBoardView)
                let gridSquareSize = (self.board.scrollView.frame.height*(1/6))
                let row = Int(gridlocation.x/gridSquareSize)
                let column = Int(gridlocation.y/gridSquareSize)
                let x = CGFloat(row)*gridSquareSize+self.board.grayLineWidth
                let y = CGFloat(column)*gridSquareSize+self.board.grayLineWidth
                var found:Bool = false
                for items in self.board.currentTiles {
                    if((items[0] as! Int) == column && (items[1] as! Int) == row) {
                        copyTile.removeFromSuperview()
                        self.isHidden = false
                        found = true
                        break
                    }
                }
                if(self.board.grid[column][row] == nil && !found && checkGrid(column, row)) {
                    self.board.tempGrid[column][row] = copyTile
                    self.board.currentTiles.append([column, row, self.copyTile])
                    copyTile.removeFromSuperview()
                    board.brownBoardView.addSubview(copyTile)
                    copyTile.frame = CGRect(x: x, y: y, width: gridSquareSize-(self.board.grayLineWidth*2), height: gridSquareSize-(self.board.grayLineWidth*2))
                    copyTile.layer.borderWidth = 1
                    self.board.editing = true
                    for items in self.board.player[0].hand {
                        items.layer.borderColor = UIColor.red.cgColor
                    }
                }
                else {
                    copyTile.removeFromSuperview()
                    self.isHidden = false
                }
            }
            else {
                copyTile.removeFromSuperview()
                self.isHidden = false
                if(!self.board.editing && abs((location.x+location.y)-startLocation) <= self.frame.width*(1/1000000)) {
                    if(self.layer.borderColor != UIColor.purple.cgColor) {
                        self.layer.borderColor = UIColor.purple.cgColor
                    }
                    else {
                        self.layer.borderColor = UIColor.red.cgColor
                    }
                }
            }
            self.moving = false
        }
    }
    
    //This checks the grid to the left and right and up and down to make sure the tile can be placed. I could have condensed the code a little, but it would still be the same thing.
    func checkGrid(_ row: Int, _ column:Int) -> Bool {
        var x = row, y = column-1
        while(y >= 0) {
            let tileToLeft = self.board.tempGrid[x][y]
            if(tileToLeft != nil) {
                let sameShape = tileToLeft!.shape == self.shape
                let sameColor = tileToLeft!.color == self.color
                if((sameColor && sameShape) || (!sameShape && !sameColor)) {
                    return false
                }
                y -= 1
            }
            else {
                break
            }
        }
        y = column+1
        while(y <= self.board.maxLine[0]) {
            let tileToTheRight = self.board.tempGrid[x][y]
            if(tileToTheRight != nil) {
                let sameShape = tileToTheRight!.shape == self.shape
                let sameColor = tileToTheRight!.color == self.color
                if((sameColor && sameShape) || (!sameShape && !sameColor)) {
                    return false
                }
                y += 1
            }
            else {
                break
            }
        }
        x = row-1
        y = column
        while(x >= 0) {
            let tileToTop = self.board.tempGrid[x][y]
            if(tileToTop != nil) {
                let sameShape = tileToTop!.shape == self.shape
                let sameColor = tileToTop!.color == self.color
                if((sameColor && sameShape) || (!sameShape && !sameColor)) {
                    return false
                }
                x -= 1
            }
            else {
                break
            }
        }
        x = row+1
        while(x <= self.board.maxLine[1]) {
            let tileToBot = self.board.tempGrid[x][y]
            if(tileToBot != nil) {
                let sameShape = tileToBot!.shape == self.shape
                let sameColor = tileToBot!.color == self.color
                if((sameColor && sameShape) || (!sameShape && !sameColor)) {
                    return false
                }
                x += 1
            }
            else {
                break
            }
        }
        return true
    }
    
    //This returns a copy of the tile, so I can move it around and use it as necessary
    override func copy() -> Any {
        let copy = Tile(shape: self.shape, color: self.color, board: self.board)
        return copy
    }
    
    //This function creates the path for the vaious tiles shapes so I can make the game with different shapes. I created all of these paths.
    func createBezierPath() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        switch self.shape {
        case "Square":
            bezierPath.move(to: CGPoint(x: self.frame.width*0.2, y: self.frame.height*0.2))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.8, y: self.frame.height*0.2))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.8, y: self.frame.height*0.8))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.2, y: self.frame.height*0.8))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.2, y: self.frame.height*0.2))
            break
        case "8-sided Star":
            bezierPath.move(to: CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.1))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.575, y: self.frame.height*0.3))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.8, y: self.frame.height*0.2))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.7, y: self.frame.height*0.4))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.9, y: self.frame.height*0.5))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.7, y: self.frame.height*0.6))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.8, y: self.frame.height*0.8))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.575, y: self.frame.height*0.7))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.9))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.425, y: self.frame.height*0.7))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.2, y: self.frame.height*0.8))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.3, y: self.frame.height*0.6))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.1, y: self.frame.height*0.5))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.3, y: self.frame.height*0.4))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.2, y: self.frame.height*0.2))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.425, y: self.frame.height*0.3))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.1))
            break
        case "Circle":
            return UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: CGFloat(self.frame.width*(1/3)), startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true)
        case "diamond-Star":
            bezierPath.move(to: CGPoint(x: self.frame.width*0.15, y: self.frame.height*0.15))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.325))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.85, y: self.frame.height*0.15))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.675, y: self.frame.height*0.5))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.85, y: self.frame.height*0.85))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.675))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.15, y: self.frame.height*0.85))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.325, y: self.frame.height*0.5))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.15, y: self.frame.height*0.15))
            break
        case "4-Leaf Clover":
            bezierPath.move(to: CGPoint(x: self.frame.width*0.35, y: self.frame.height*0.35))
            bezierPath.addQuadCurve(to: CGPoint(x: self.frame.width*0.65, y: self.frame.height*0.35), controlPoint: CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.2*(-1)))
            bezierPath.addQuadCurve(to: CGPoint(x: self.frame.width*0.65, y: self.frame.height*0.65), controlPoint: CGPoint(x: self.frame.width*1.2, y: self.frame.height*0.5))
            bezierPath.addQuadCurve(to: CGPoint(x: self.frame.width*0.35, y: self.frame.height*0.65), controlPoint: CGPoint(x: self.frame.width*0.5, y: self.frame.height*1.2))
            bezierPath.addQuadCurve(to: CGPoint(x: self.frame.width*0.35, y: self.frame.width*0.35), controlPoint: CGPoint(x: self.frame.width*0.2*(-1), y: self.frame.height*0.5))
            break
        case "Diamond":
            bezierPath.move(to: CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.1))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.9, y: self.frame.height*0.5))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.9))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.1, y: self.frame.height*0.5))
            bezierPath.addLine(to: CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.1))
            break
        default:
            break
        }
        return bezierPath
    }
}
