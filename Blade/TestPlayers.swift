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
		if let card = self.handCards.popLast() {
			let action = Action(playerType: self.type, actionType: .PlayHand, playedHand: card)
			callback(action)
		} else {
			let action = Action(playerType: self.type, actionType: .OutOfCard, playedHand: nil)
			callback(action)
		}
	}
}