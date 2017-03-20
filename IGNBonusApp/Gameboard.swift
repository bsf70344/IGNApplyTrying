//
//  Gameboard.swift
//  IGNBonusApp
//
//  Created by Bradley French on 3/15/17.
//  Copyright © 2017 Bradley French. All rights reserved.
//

import UIKit

class Gameboard: UIView, UIScrollViewDelegate {

    //Tiles
    var tiles:Tiles!
    
    //The board is on a scrollView
    var scrollView:UIScrollView!
    
    //The contentView for the scroll
    var brownBoardView:UIView!
    
    //width, height -- these are maximums on the board
    var maxLine:[Int] = [0, 0]
    
    //The players hand
    var playersBoard:UIView!
    
    //The players
    var player:[Players] = []
    
    //This is for the lines on the board
    lazy var grayLineWidth:CGFloat = self.frame.height*0.0025
    
    //This is the actual grid
    var grid:[[Tile?]] = [[], [], [], [], [], []]
    
    //This is what is currently on the grid, but not locked in place
    var currentTiles:[[Any]] = []
    
    //The controller
    var controller:ViewController!
    
    //Used to make sure they cant change tiles while editing the board
    var editing:Bool! = false
    
    //Temp grid
    var tempGrid:[[Tile?]]!
    
    //Labels for score
    var scoreLabels:[UILabel] = []
    
    //The score
    var score:[Int] = [0, 0]
    
    convenience init(frame: CGRect, controller:ViewController) {
        self.init(frame: frame)
        self.controller = controller
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height*0.8))
        self.addSubview(self.scrollView)
        
        //SetupUI
        createBoard()
        addButtons()
    }
    
    //I create the board, and make sure there is enough room for 6 tiles at all times.
    func createBoard() {
        self.backgroundColor = UIColor.black
        self.scrollView.contentSize = self.frame.size
    
        brownBoardView = UIView(frame: scrollView.bounds)
        brownBoardView.backgroundColor = UIColor.brown
        self.scrollView.addSubview(brownBoardView)
        
        playersBoard = UIView(frame: CGRect(x: 0, y: self.frame.height*0.8, width: self.frame.width, height: self.frame.height*0.2))
        playersBoard.backgroundColor = UIColor(colorLiteralRed: 26/255, green: 26/255, blue: 111/255, alpha: 1)
        self.addSubview(playersBoard)
        
        self.createRowOrColumn(count: 5, direction: 0, addToGrid: false)
        self.createRowOrColumn(count: 14, direction: 1, addToGrid: false)
        
        adjustLines()
        tempGrid = grid
        
        //This creates the labels
        for i in 0 ..< 4 {
            var text:[String] = ["AI:", String(score[0]), "You:", String(score[1])]
            let x = (playersBoard.frame.width-playersBoard.frame.height*6)/4
            let label = UILabel(frame: CGRect(x: (playersBoard.frame.height*6)+(x*CGFloat(i)), y: playersBoard.frame.height/2, width: x, height: playersBoard.frame.height/2))
            label.text = text[i]
            label.textAlignment = .center
            label.textColor = UIColor.white
            label.numberOfLines = 1
            self.scoreLabels.append(label)
            self.playersBoard.addSubview(label)
        }
    }
    
    //This method adds rows or columns depending on how the user plays. This is the method that makes sure there is always 6 tiles on the board in every direction to make sure we dont prohibit gameplay
    func createRowOrColumn(count:Int, direction:Int, addToGrid:Bool = true) {
        for _ in 0 ..< count {
            var rect = CGRect(x: 0, y: CGFloat(maxLine[1]+1)*(self.scrollView.frame.height*(1/6))-(self.grayLineWidth/2), width: self.scrollView.contentSize.width, height: self.grayLineWidth)
            if(direction == 1) {
                rect = CGRect(x: CGFloat(maxLine[0]+1)*(self.scrollView.frame.height*(1/6))-(self.grayLineWidth/2), y: 0, width: self.grayLineWidth, height: self.scrollView.contentSize.height)
            }
            else {
                if(addToGrid) {
                    self.grid.append([])
                }
            }
            let grayLine = UIView(frame: rect)
            grayLine.tag = 2
            grayLine.backgroundColor = UIColor.gray
            brownBoardView.addSubview(grayLine)
            maxLine[abs(direction-1)] += 1
        }
    }
    
    //This moves the lines over and increases various contentSizes. As we add more rows and columns, everything had to increase in width or height, it happens here.
    func adjustLines() {
        self.scrollView.contentSize = CGSize(width: CGFloat(maxLine[0]+1)*self.scrollView.frame.height*(1/6), height: CGFloat(maxLine[1]+1)*self.scrollView.frame.height*(1/6))
        brownBoardView.frame = CGRect(x: brownBoardView.frame.minX, y: brownBoardView.frame.minY, width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height)
        for views in brownBoardView.subviews {
            if(views.tag == 2) {
                let rect = (views.frame.height > views.frame.width) ? CGRect(x: views.frame.minX, y: views.frame.minY, width: views.frame.width, height: self.scrollView.contentSize.height)
                    : CGRect(x: views.frame.minX, y: views.frame.minY, width: self.scrollView.contentSize.width, height: views.frame.height)
                views.frame = rect
            }
        }
        for i in 0 ..< grid.count {
            for _ in 0 ..< (maxLine[0]-grid[i].count+1) {
                grid[i].append(nil)
            }
        }
    }
    
    //This is the initial method to create the tiles in the player's hand to show on the board
    func createTiles(count:Int) {
        let width = playersBoard.frame.height
        for i in 0 ..< player[0].hand.count {
            if(i >= 6-count) {
                player[0].hand[i].frame = CGRect(x: width*CGFloat(i), y: 0, width: width, height: width)
                player[0].hand[i].layer.borderColor = UIColor.red.cgColor
                player[0].hand[i].layer.borderWidth = 1
                playersBoard.addSubview(player[0].hand[i])
            }
        }
    }
    
    //This creates the 3 buttons  on the bottom left
    func addButtons() {
        var startPos = self.playersBoard.frame.height*6
        var titles:[String] = ["Undo", "Change", "Finish"]
        for i in 0 ..< 3 {
            let width = (playersBoard.frame.width-playersBoard.frame.height*6)/3
            let button = UIButton(frame: CGRect(x: startPos, y: 0, width: width, height: playersBoard.frame.height*0.5))
            if(i == 1) {
                button.isEnabled = false
                button.tag = 12
            }
            button.backgroundColor = UIColor.black
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.red.cgColor
            button.titleLabel?.textColor = UIColor.black
            button.titleLabel?.textAlignment = .center
            button.setTitle(titles[i], for: .normal)
            button.addTarget(self, action: NSSelectorFromString(titles[i].lowercased()), for: .touchUpInside)
            startPos += width
            playersBoard.addSubview(button)
        }
    }
    
    //This function allows for undo
    func undo() {
        tempGrid = grid
        self.editing = false
        for items in currentTiles {
            let tile = items[2] as! Tile
            tile.removeFromSuperview()
        }
        currentTiles = []
        for items in player[0].hand {
            if(items.isHidden) {
                items.isHidden = false
            }
        }
    }
    
    //This is the change function.
    func change() {
        if(!editing) {
            var tiles:[Tile] = []
            var positions:[Int] = []
            for items in player[0].hand {
                if(items.layer.borderColor == UIColor.purple.cgColor) {
                    let index = player[0].hand.index(of: items)!
                    tiles.append(items)
                    player[0].hand.remove(at: index)
                    positions.append(index)
                    items.removeFromSuperview()
                }
                else {
                    if(positions.count > 0) {
                        UIView.animate(withDuration: 0.75, animations: {
                            let moveLeft = CGFloat(positions.count)*self.playersBoard.frame.height
                            items.frame = CGRect(x: items.frame.minX-moveLeft, y: 0, width: self.playersBoard.frame.height, height: self.playersBoard.frame.height)
                        })
                    }
                }
            }
            getTiles(count: positions.count, trade: true, tilesToAdd: tiles)
        }
        self.AIMove()
        for items in self.playersBoard.subviews {
            if(items.tag == 12) {
                (items as! UIButton).isEnabled = true
            }
        }
    }
    
    //This function indicates when a player is finished with their turn. After they are done, the AI goes. Then it is their turn again. The AI moves pretty quick.
    func finish() {
        self.playersBoard.isUserInteractionEnabled = false
        if(currentTiles.count > 0) {
            self.editing = false
            //x - close to 0, y - close to 0       x - close to max, y - close to max
            var minMax:[Int] = [6, 6, maxLine[0]-6, maxLine[1]-6]
            let currentMax = maxLine
            for items in currentTiles {
                let tile = (items[2] as! Tile)
                grid[items[0] as! Int][items[1] as! Int] = tile
                tile.layer.borderWidth = 0
                
                var item = items[0] as! Int
                if(item < minMax[0]) {
                    minMax[0] = item
                }
                if(item > minMax[3]) {
                    minMax[3] = item
                }
                item = items[1] as! Int
                if(item < minMax[1]) {
                    minMax[1] = item
                }
                if(item > minMax[2]) {
                    minMax[2] = item
                }
                print(items[0], items[1])
                addSix(player: 1, row: items[0] as! Int, column: items[1] as! Int)
            }
            
            //This is how much the tiels will move and how many rows and columns need to be created
            let movementX = (6-minMax[1]), movementY = (6-minMax[0])
            let widthChanges = (6-(currentMax[0]-minMax[2]))+movementX
            let heightChanges = (6-(currentMax[1]-minMax[3]))+movementY
            if(currentMax[0]-minMax[2] <= 5 || minMax[1] < 6) {
                createRowOrColumn(count: widthChanges, direction: 1, addToGrid: true)
                adjustLines()
            }
            if(currentMax[0]-minMax[3] <= 5 || minMax[0] < 6) {
                createRowOrColumn(count: heightChanges, direction: 0, addToGrid: true)
                adjustLines()
            }
            tempGrid = grid
            if(minMax[1] < 6 || minMax[0] < 6) {
                for i in (0 ... grid.count-1) {
                    for j in (0 ... grid[i].count-1).reversed() {
                        let currentTile = grid[i][j]
                        if(currentTile != nil) {
                            tempGrid[i+movementY][j+movementX] = currentTile
                            UIView.animate(withDuration: 1.0, animations: {
                                //Movement of tiles
                                currentTile!.frame = CGRect(x: currentTile!.frame.minX+((self.scrollView.frame.height*(1/6))*CGFloat(movementX)), y: currentTile!.frame.minY+((self.scrollView.frame.height*(1/6))*CGFloat(movementY)), width: currentTile!.frame.width, height: currentTile!.frame.height)
                            })
                            let item:Tile? = (i < 6 || j < 6) ? nil : grid[i-movementY][j-movementX]
                            tempGrid[i][j] = item
                        }
                    }
                }
            }
            grid = tempGrid
            //
            currentTiles = []
            var count:Int = 0
            for items in player[0].hand {
                if(items.isHidden) {
                    player[0].hand.remove(at: player[0].hand.index(of: items)!)
                    items.removeFromSuperview()
                    count += 1
                }
                else {
                    UIView.animate(withDuration: 0.75, animations: {
                        let moveLeft = CGFloat(count)*self.playersBoard.frame.height
                        items.frame = CGRect(x: items.frame.minX-moveLeft, y: 0, width: self.playersBoard.frame.height, height: self.playersBoard.frame.height)
                    })
                }
            }
            changeScore(person: 1, score: count)
            getTiles(count: count)
            self.tempGrid = grid
            self.AIMove()
            for items in self.playersBoard.subviews {
                if(items.tag == 12) {
                    (items as! UIButton).isEnabled = true
                }
            }
        }
        else if(self.tiles.count == 0) {
            AIMove()
        }
    }
    
    //This method does the hard work in getting Tiles for either player. We get tiles depending on how many they need and how many is left
    func getTiles(count:Int, player:Int = 0, trade:Bool = false, tilesToAdd:[Tile]? = nil) {
        let numOfTiles = self.controller.tiles.count > count ? count : self.controller.tiles.count
        self.player[player].hand += self.controller.tiles.getTile(count: numOfTiles, trade: trade, tradeTiles: tilesToAdd)
        UIView.animate(withDuration: 0.75, animations: {
            self.createTiles(count: count)
        })
    }
    
    //Change the score of a specific person, with a score parameter
    func changeScore(person: Int, score:Int) {
        self.score[person] += score
        scoreLabels[(person*2)+1].text = String(self.score[person])
    }
    
    //Tihs method is how the computer makes their turn. He just checks to see if he can add to any previous tiles, so he isn't just placing tiles anywhere.
    func AIMove() {
        var changed:Int = 0
        for tiles in player[1].hand {
            print(tiles.shape, tiles.color)
            var stop:Bool = false, x:Int = 0, y:Int = 0
            for i in 6 ..< grid.count-1 {
                for j in 6 ..< grid[i].count-1 {
                    if(grid[i][j] != nil) {
                        if(tiles.checkGrid(i, j-1) && grid[i][j-1] == nil) {
                            print("left")
                            x = i; y = j-1
                            stop = true
                        }
                        else if(tiles.checkGrid(i, j+1) && grid[i][j+1] == nil) {
                            print("right")
                            x = i; y = j+1
                            stop = true
                        }
                        else if(tiles.checkGrid(i-1, j) && grid[i-1][j] == nil) {
                            print("up")
                            x = i-1; y = j
                            stop = true
                        }
                        else if(tiles.checkGrid(i+1, j) && grid[i+1][j] == nil) {
                            print("down")
                            x = i+1; y = j
                            stop = true
                        }
                        if(stop) {
                            print(x, y)
                            self.grid[x][y] = tiles
                            self.tempGrid = self.grid
                            addSix(player: 0, row: x, column: y)
                            UIView.animate(withDuration: 1.5, animations: {
                                tiles.frame = CGRect(x: (self.scrollView.frame.height*(1/6)*CGFloat(y))+((self.grayLineWidth)/2), y: (self.scrollView.frame.height*(1/6)*CGFloat(x))+((self.grayLineWidth)/2), width: self.scrollView.frame.height*(1/6)-self.grayLineWidth, height: self.scrollView.frame.height*(1/6)-self.grayLineWidth)
                                self.scrollView.addSubview(tiles)
                                self.player[1].hand.remove(at: self.player[1].hand.index(of: tiles)!)
                                changed += 1
                            })
                            break
                        }
                        else {
                            stop = false
                        }
                    }
                }
                if(stop) {
                    break
                }
            }
        }
        changeScore(person: 0, score: changed)
        getTiles(count: changed, player: 1)
        if(self.tiles.count == 0 && player[1].hand.count == (player[1] as! AI).oldHand) {
            self.isUserInteractionEnabled = false
            let label = UILabel(frame: CGRect(x: 0, y: self.frame.height*0.4, width: self.frame.width, height: self.frame.height*0.2))
            var title = ""
            let CPscore = self.score[0]-self.score[1]
            let PLAYscore = self.score[1]-self.score[0]
            if(self.score[0] > self.score[1]) {
                title += "Computer beat you by \(CPscore)"
            }
            else {
                title += "You beat the computer by \(PLAYscore)"
            }
            label.text = title
            label.textAlignment = .center
            label.backgroundColor = UIColor.black
            label.textColor = UIColor.white
            self.addSubview(label)
        }
        (player[1] as! AI).oldHand = player[1].hand.count
        self.playersBoard.isUserInteractionEnabled = true
    }
    
    //This method just checks to see if a row or column was complete, and if so, to add 6 to the person's score
    func addSix(player:Int, row:Int, column:Int) {
        var count:Int = 0
        //left to right
        if(column + 1 < maxLine[0]-1) {
            for i in (column+1 ... maxLine[0]-1) {
                if(grid[row][i] != nil) {
                    count += 1
                }
                else {
                    break
                }
            }
        }
        if(column - 1 > 0) {
            for i in (0 ... column-1).reversed() {
                if(grid[row][i] != nil) {
                    count += 1
                }
                else {
                    break
                }
            }
        }
        print("Count 1, \(count)")
        if(count == 5) {
            changeScore(person: player, score: 6)
        }
        count = 0
        if(row+1 < maxLine[1]-1) {
            for i in (row+1 ... maxLine[1]-1) {
                if(grid[i][column] != nil) {
                    count += 1
                }
                else {
                    break
                }
            }
        }
        if(row - 1 > 0) {
            for i in (0 ... row-1).reversed() {
                if(grid[i][column] != nil) {
                    count += 1
                }
                else {
                    break
                }
            }
        }
        print("Count 2, \(count)")
        if(count == 5) {
            changeScore(person: player, score: 6)
        }
    }
}


