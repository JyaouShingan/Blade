//
//  Action.swift
//  Blade
//
//  Created by Peter Chen on 2015-11-24.
//  Copyright © 2015 Peter Chen. All rights reserved.
//

import Foundation

typealias ActionID = Int

enum ActionType: UInt {
	case PlayHand = 0
	case OutOfCard
	case Quit
}

enum ActionFeedback {
	case Accepted
	case Rejected(reason: String)
}

func ==(lhs:ActionFeedback, rhs:ActionFeedback) -> Bool {
	switch(lhs, rhs) {
	case (.Accepted, .Accepted):
		return true
	case (.Rejected( _), .Rejected( _)):
		return true
	default:
		return false
	}
}

struct Action {
	var id: Int
	var playerType: PlayerType
	var actionType: ActionType
	var playedIndex: Int?
	var playedHand: Card?
}

class ActionManager {
	struct IDPool {
		var nextID: Int = 0
	}
	private var idPool: IDPool = IDPool()

	func getNextID() -> Int {
		return self.idPool.nextID++
	}

	func createAction(playerType: PlayerType, actionType: ActionType, playedIndex: Int?, playedHand: Card?) -> Action {
		return Action(id: self.getNextID(), playerType: playerType, actionType: actionType, playedIndex: playedIndex, playedHand: playedHand)
	}
}