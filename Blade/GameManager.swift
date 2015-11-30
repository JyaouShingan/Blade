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
	case Error
}

enum GameMode {
	case Normal
	case NoRestriction
}
//
//protocol PlayerDataSource: class {
//	func getHandcard(card: Card)
//	func requestAction(callback: ActionCallback)
//	func updateGameStatus(status: GameStatus)
//}

class DeskStack {
	var cardStack: [Card] = []
	var point: Int = 0
	
	func addWeaponCard(card: Card) {
		self.cardStack.append(card)
		self.point += card.weaponNum!
	}
	
	func removeTopCard() {
		if let card = self.cardStack.popLast() {
			self.point -= card.weaponNum!
		}
	}
}

class GameManager {
	private let managerQueue = dispatch_queue_create("game_manager_queue", DISPATCH_QUEUE_SERIAL)
	
	private var mode: GameMode
	
	private var deck: Deck!
	private var state: GameState {
		didSet {
			dispatch_async(managerQueue) {
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
	}
	
	func start() {
		self.state = .Start
	}
	
	func terminate() {
		
	}
	
	// MARK:- Game Process
	
	private func processState() {
		print("Enter new state: \(self.state)")
		switch self.state {
		case .Start:
			self.dealing()
		case .PointDual:
			self.pointDual()
		case .HostTurn:
			self.startHostStep()
		case .OpponentTurn:
			self.startOppoStep()
		case .End:
			print("END")
		default:
			()
		}
	}
	
	private func dealing() {
		self.deck = Deck()
		for i in 0..<18 {
			if let card = self.deck.next() {
				if i % 2 == 0 {
					self.host?.getHandcard(card)
				} else {
					self.opponent?.getHandcard(card)
				}
			}
		}
		self.state = .PointDual
	}
	
	private func pointDual() {
		let hostCard = self.getFirstWeaponCard()
		let opponentCard = self.getFirstWeaponCard()
		
		self.hostCardStack.addWeaponCard(hostCard)
		self.oppoCardStack.addWeaponCard(opponentCard)
		
		print("--PointDual--")
		print("Host: \(hostCard)")
		print("Opponent: \(opponentCard)")
		self.state = hostCard.weaponNum! < opponentCard.weaponNum! ? .HostTurn : .OpponentTurn
	}
	
	private func startHostStep() {
		self.host?.requestAction({ (action) -> () in
			self.registerAction(action)
		})
	}
	
	private func startOppoStep() {
		self.opponent?.requestAction({ (action) -> () in
			self.registerAction(action)
		})
	}
	
	private func processPlayHand(action: Action) {
		let processCard = { (card: Card, actionStack: DeskStack, oppoStack: DeskStack) -> Void in
			print("Played card: \(card)")
			switch card.cardType {
			case .Weapon:
				actionStack.addWeaponCard(card)
			case .Blot:
				oppoStack.removeTopCard()
			case .Mirror:
				let tempStack = actionStack.cardStack
				let tempPoint = actionStack.point
				actionStack.cardStack = oppoStack.cardStack
				actionStack.point = oppoStack.point
				oppoStack.cardStack = tempStack
				oppoStack.point = tempPoint
			default:
				()
			}
			print("Host Point: \(self.hostCardStack.point) Stack: \(self.hostCardStack.cardStack)")
			print("Oppo Point: \(self.oppoCardStack.point) Stack: \(self.oppoCardStack.cardStack)")
		}
		
		if action.playerType == .Host && self.state == .HostTurn {
			print("Host played card")
			processCard(action.playedHand!, self.hostCardStack, self.oppoCardStack)
			self.state = .OpponentTurn
		} else if action.playerType == .Opponent && self.state == .OpponentTurn {
			print("Opponent played card")
			processCard(action.playedHand!, self.oppoCardStack, self.hostCardStack)
			self.state = .HostTurn
		} else {
			print("ERROR: Action received during others turn")
		}
	}
	
	private func registerAction(action: Action) {
		switch action.actionType {
		case .PlayHand:
			self.processPlayHand(action)
		case .OutOfCard:
			self.state = .End
		case .Quit:
			()
		}
	}
	
	// MARK:- Helper
	
	private func getFirstWeaponCard() -> Card {
		var card = self.deck.cardDeck.popLast()!
		while card.cardType != .Weapon {
			card = self.deck.cardDeck.popLast()!
		}
		return card
	}
}