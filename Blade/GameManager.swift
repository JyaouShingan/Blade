//
//  GameManager.swift
//  Blade
//
//  Created by Peter Chen on 2015-11-24.
//  Copyright © 2015 Peter Chen. All rights reserved.
//

import Foundation

typealias ActionCallback = ((Action) -> ())

enum GameState {
	case Hanging
	case Start
	case PointDual
	case HostTurn
	case OpponentTurn
	case End
	case OutOfDeck
    case Reforge // Under TEST
	case Error
}

enum GameMode {
	case Normal
	case NoRestriction
}

let ManagerQueue = dispatch_queue_create("game_manager_queue", DISPATCH_QUEUE_SERIAL)
let BladeNewStateNotfication = "BladeNewStateNotfication"

class DeskStack {
	var cardStack: [Card] = []
	var point: Int = 0
    var graveyard: Card?
	
	func addWeaponCard(card: Card) {
		self.cardStack.append(card)
		if let wCard = card as? WeaponCard {
			self.point += wCard.weaponNum
		}
	}
	
	func removeTopCard() {
		if let card = self.cardStack.popLast(), let wCard = card as? WeaponCard {
			self.point -= wCard.weaponNum
            let copy = wCard as Card
            self.graveyard = copy
            //print("\(self.graveyard) last printed") DEBUG USAGE
		}
	}

	func clear() {
		self.cardStack.removeAll()
		self.graveyard = nil
		self.point = 0
	}
}

class GameManager {
	
	private var rule: Ruler?
	
	private var mode: GameMode
	private var deck: Deck!
	private var state: GameState {
		didSet {
			dispatch_async(ManagerQueue) {
				self.processState()
			}
		}
	}
	
	var host: Player?
	var opponent: Player?
	
	private var hostCardStack = DeskStack()
	private var oppoCardStack = DeskStack()
	
	init(gameMode: GameMode, host: Player, opponent: Player) {
		self.mode = gameMode
		self.state = .Hanging
		self.host = host
		self.opponent = opponent
		
		self.rule = Ruler(manager: self)
		
		self.host?.actionCallback = {[weak self] (action: Action) -> Void in
			self?.registerAction(action)
		}
		self.opponent?.actionCallback = {[weak self] (action: Action) -> Void in
			self?.registerAction(action)
		}
	}
	
	func start() {
		self.state = .Start
	}
	
	func terminate() {
		self.hostCardStack.clear()
		self.oppoCardStack.clear()
	}
	
	func setState(state:GameState) {
		self.state = state
	}
	
	func getState() -> GameState {
		return self.state
	}
	
	func getStack(id:String) -> DeskStack{
		return id == "host" ? self.hostCardStack : self.oppoCardStack
	}
	
	func process(action:Action) -> ActionFeedback{
		return processPlayHand(action)
	}
	
	// MARK:- Game Process
	
	private func processState() {
		print("Enter new state: \(self.state)")
		let gameStatus = GameStatus(hostDesk: self.hostCardStack, oppoDesk: self.oppoCardStack, state: self.state)
		self.host?.gameStatus = gameStatus
		self.opponent?.gameStatus = gameStatus

		NSNotificationCenter.defaultCenter().postNotificationName(BladeNewStateNotfication, object: self, userInfo: nil)

		switch self.state {
		case .Start:
			self.dealing()
		case .PointDual:
			self.pointDual()
		case .HostTurn:
			self.startHostStep()
		case .OpponentTurn:
			self.startOppoStep()
        case .Reforge:
            self.reforge()
		case .End:
			print("END")
		default:
			()
		}
	}
	
	private func dealing() {
		self.deck = Deck()
		self.rule!.dealing(self.deck)
	}
	
	private func reforge() {
		self.rule!.reforge()
	}
	
	private func pointDual() {
		self.rule!.pointDual(self.deck)
	}

	private func startHostStep() {
		self.rule!.startHostStep()
	}
	
	private func startOppoStep() {
		self.rule!.startOppoStep()
	}
	
	func registerAction(action: Action) {
		var feedback: ActionFeedback
		switch action.actionType {
		case .PlayHand:
			feedback = self.process(action)
		case .OutOfCard:
			self.setState(.End)
			feedback = .Accepted
		case .Quit:
			feedback = .Accepted
			()
		}
		
		switch action.playerType {
		case .Host:
			self.host?.actionFeedback(action.id, type: feedback)
		case .Opponent:
			self.opponent?.actionFeedback(action.id, type: feedback)
		}
	}
	
	private func processPlayHand(action: Action) -> ActionFeedback {
		return self.rule!.processHand(action)
	}
	// MARK:- Helper
	
}