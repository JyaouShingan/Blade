//
//  Player.swift
//  Blade
//
//  Created by Peter Chen on 2015-11-24.
//  Copyright © 2015 Peter Chen. All rights reserved.
//

import Foundation

enum PlayerType {
	case Host
	case Opponent
}

class Player {
	var name: String
	var type: PlayerType
	var handCards: [Card] = []
	var gameStatus: GameStatus?
	
	weak var manager: GameManager?
	
	// MARK:- PlayerDataSource
	init(name: String, type: PlayerType) {
		self.name = name
		self.type = type
	}
	
	func getHandcard(card: Card) {
		self.handCards.append(card)
		if self.handCards.count == 9 {
			self.handCards.sortInPlace{ $0 < $1 }
			print("")
		}
	}
	
	func requestAction(callback: ActionCallback) {
		
	}
	
	func updateGameStatus(status: GameStatus) {
		
	}
}