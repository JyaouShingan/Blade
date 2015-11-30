//
//  Action.swift
//  Blade
//
//  Created by Peter Chen on 2015-11-24.
//  Copyright © 2015 Peter Chen. All rights reserved.
//

import Foundation

enum ActionType {
	case PlayHand
	case OutOfCard
	case Quit
}

struct Action {
	var playerType: PlayerType
	var actionType: ActionType
	var playedHand: Card?
}