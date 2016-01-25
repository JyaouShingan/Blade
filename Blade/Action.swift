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

enum ActionFeedback: UInt {
	case Accepted = 0
	case Rejected
}

struct Action {
	var id: Int
	var playerType: PlayerType
	var actionType: ActionType
	var playedHand: Card?
}

class ActionManager {
	struct IDPool {
		var nextID: Int = 0
	}
	static private var idPool: IDPool = IDPool()

	static func getNextID() -> Int {
		return self.idPool.nextID++
	}

	static func createAction(playerType: PlayerType, actionType: ActionType, playedHand: Card?) -> Action {
		return Action(id: self.getNextID(), playerType: playerType, actionType: actionType, playedHand: playedHand)
	}
}