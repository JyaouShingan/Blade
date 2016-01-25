//
//  TestPlayers.swift
//  Blade
//
//  Created by Peter Chen on 2015-11-30.
//  Copyright © 2015 Peter Chen. All rights reserved.
//

import Foundation

class TestPlayer: Player {
	override func requestAction(callback: ActionCallback) {
		if self.handCards.count != 0 {
			let index = Int(arc4random()) % self.handCards.count
			let card = self.handCards.removeAtIndex(index)
			let action = ActionManager.createAction(self.type, actionType: .PlayHand, playedHand: card)
			self.pendingActions[action.id] = action
			callback(action)
		} else {
			let action = ActionManager.createAction(self.type, actionType: .OutOfCard, playedHand: nil)
			self.pendingActions[action.id] = action
			callback(action)
		}
	}
}