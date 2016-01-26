//
//  TestPlayers.swift
//  Blade
//
//  Created by Peter Chen on 2015-11-30.
//  Copyright © 2015 Peter Chen. All rights reserved.
//

import Foundation

class TestPlayer: Player {
	override func playHand(index index: Int) {
		let card = self.handCards[index]
		let action = self.actionManager.createAction(self.type, actionType: .PlayHand, playedIndex: index, playedHand: card)
		self.pendingActions[action.id] = action
		if let cb = self.actionCallback {
			cb(action)
		}
	}
}