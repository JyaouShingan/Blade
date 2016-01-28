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

	var actionManager = ActionManager()
	var actionCallback: ActionCallback?
	internal var pendingActions: [ActionID:Action] = [:]
	
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
		}
	}
    
	func playHand(index index: Int) {
		
	}
	
	func requestAction(callback: ActionCallback) {
		//Override func
	}
	
	func updateGameStatus(status: GameStatus) {
		//Override func
	}
	
	func sendingAction(action: Action) {
		dispatch_async(ManagerQueue) {
			self.manager?.registerAction(action)
		}
	}
	
	func actionFeedback(id: ActionID, type: ActionFeedback) {
		if let action = self.pendingActions[id] {
			self.pendingActions.removeValueForKey(id)
			switch type {
			case .Accepted:
				if let index = action.playedIndex {
					self.handCards.removeAtIndex(index)
				}
				print("Action accepted")
			case .Rejected(let msg):
				print("Action rejected: \(msg)")
			}
		}
	}
}