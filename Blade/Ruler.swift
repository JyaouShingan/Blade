//
//  GameRule.swift
//  Blade
//
//  Created by Teakay on 2016-02-02.
//  Copyright © 2016 Peter Chen. All rights reserved.
//

import Foundation

class Ruler {
	
	private weak var manager: GameManager!
	private var host: Player? {
		return self.manager.host
	}
	private var opponent: Player? {
		return self.manager.opponent
	}
	private var hostStack: DeskStack {
		return self.manager.getStack("host")
	}
	private var opponentStack: DeskStack {
		return self.manager.getStack("oppo")
	}
	var dualcount: Int?
	
	init (manager:GameManager) {
		self.manager = manager
		self.dualcount = 0
	}
	
	func dealing(deck:Deck) {
		
		for j in 0..<2 {
			if let card = deck.nextMagic() {
				if j % 2 == 0 {
					self.host?.getHandcard(card)
				} else {
					self.opponent?.getHandcard(card)
				}
			}
		}
		
		print("Dealing Part 1 Done")
		print(self.manager.host?.handCards)
		print(self.manager.opponent?.handCards)
		
		for k in 0..<4 {
			if let card = deck.next() {
				if k % 2 == 0 {
					self.host?.getHandcard(card)
				} else {
					self.opponent?.getHandcard(card)
				}
			}
		}
		
		print("Dealing Part 2 Done")
		print(self.host?.handCards)
		print(self.opponent?.handCards)
		
		deck.cardDeck += deck.magicDeck
		deck.shuffle()
		
		for i in 0..<12 {
			if let card = deck.next() {
				if i % 2 == 0 {
					self.host?.getHandcard(card)
				} else {
					self.opponent?.getHandcard(card)
				}
			}
		}
		
		print("Dealing Part 3 Done")
		print(self.host?.handCards)
		print(self.opponent?.handCards)
		
		if(deck_basic_condition()) {
			print("HAND CONDITION PASSED") // DEBUG
			self.manager.setState(.PointDual)
		}
		else {
			print("REFORGE HAPPANED BECAUSE OF HAND CONDITION ISNT SATISFIED") // DEBUG
			self.manager.setState(.Reforge)
		}
	}
	
	func reforge() {
		print("Reforge Happened")
		self.vanish()
		//TODO:simple implementation of restarting, should be more efficient
		self.manager.start()
	}
	
	func pointDual(deck:Deck) {
		do {
			//let hostCard = try self.getFirstWeaponCard()
			//let opponentCard = try self.getFirstWeaponCard()
			
			var firstCard:WeaponCard
			var secondCard:WeaponCard
			var ifReforge = false
			let hostHandMore = self.host?.handCards.count > self.opponent?.handCards.count
			let oppoHandMore = self.host?.handCards.count < self.opponent?.handCards.count
			
			repeat{
				firstCard = try self.getFirstWeaponCard(deck)
				secondCard = try self.getFirstWeaponCard(deck)
				
				print("--PointDual--")
				print("Host: \(firstCard)")
				print("Opponent: \(secondCard)")
				self.dualcount!++
				
				print("Dual Total Times: \(self.dualcount!)")
				
				if(self.dualcount == 4){
					print("re-forge occurs")
					ifReforge = true
					break
				}
				
			}while(firstCard.weaponNum == secondCard.weaponNum)
			
			print("PointDual Finished")
			
			if (hostHandMore && firstCard.weaponNum > secondCard.weaponNum) ||
				(oppoHandMore && secondCard.weaponNum > firstCard.weaponNum) {
					swap(&firstCard, &secondCard)
					print("Background blackhand swapped")
			}
			
			if ifReforge {
				self.manager.setState(.Reforge)
			} else {
				self.hostStack.addWeaponCard(firstCard)
				self.opponentStack.addWeaponCard(secondCard)
				
				firstCard.weaponNum < secondCard.weaponNum ?
					self.manager.setState(.HostTurn) :
					self.manager.setState(.OpponentTurn)
			}
		} catch _ {
			self.manager.setState(.Error)
		}
	}
	
	func processHand(action:Action) -> ActionFeedback {
		let notRevivable = { [weak self] (card:Card) -> Bool in
			switch action.playerType {
				
			case .Host:
				if self!.opponentStack.point - self!.hostStack.point > (card as! WeaponCard).weaponNum {
					return true
				}
			case .Opponent:
				if self!.hostStack.point - self!.opponentStack.point > (card as! WeaponCard).weaponNum {
					return true
				}
			}
			return false
		}
		
		let processCard = { (card: Card, actionStack: DeskStack, oppoStack: DeskStack) -> ActionFeedback in
			print("Played card: \(card)")
			switch card.cardType {
			case .Weapon:
				if self.ifHandOnlyMagic(action) {
					return .Rejected(reason: "Hand cannot contain only magic card")
				}
				else if card.sortIndex == 0 && actionStack.graveyard != nil {
					print(actionStack.graveyard) // debug
					if let revived = actionStack.graveyard {
						if notRevivable(revived) { return .Rejected(reason: "Not Enough Points") }
						actionStack.addWeaponCard(revived)
						actionStack.graveyard = nil
						print(actionStack.graveyard) // debug
					} else {
						return .Rejected(reason: "No Card in GraveYard")
					}
				} else {
					switch action.playerType {
						
					case .Host:
						if self.opponentStack.point - self.hostStack.point > (action.playedHand as! WeaponCard).weaponNum {
							return .Rejected(reason: "Must play a card larger than difference")
						}
					case .Opponent:
						if self.hostStack.point - self.opponentStack.point > (action.playedHand as! WeaponCard).weaponNum {
							return .Rejected(reason: "Must play a card larger than difference")
						}
					}
					actionStack.addWeaponCard(card)
				}
			case .Magic:
				if let card = card as? MagicCard {
					switch card.magicType {
					case .Bolt:
						if oppoStack.cardStack.isEmpty {
							return .Rejected(reason: "Other's desk is empty")
						} else {
							oppoStack.removeTopCard()
						}
					case .Mirror:
						let tempStack = actionStack.cardStack
						let tempPoint = actionStack.point
						actionStack.cardStack = oppoStack.cardStack
						actionStack.point = oppoStack.point
						oppoStack.cardStack = tempStack
						oppoStack.point = tempPoint
					case .Bless:
						let point = actionStack.point
						let copy = GuardianCopy()
						copy.weaponNum = point
						switch action.playerType {
						case .Host:
							if oppoStack.point > self.hostStack.point * 2 || self.hostStack.point == 0{
								return .Rejected(reason: "Must play a card larger than difference")
							}
						case .Opponent:
							if self.hostStack.point > self.opponentStack.point * 2 || self.opponentStack.point == 0{
								return .Rejected(reason: "Must play a card larger than difference")
							}
						}
						actionStack.addWeaponCard(copy)
					}
				}
				
			default:
				()
			}
			return .Accepted
		}
		
		let checkEqual = { [weak self] () -> Bool in
			if self?.hostStack.point == self?.opponentStack.point {
				print("Tie, clear desk and redraw")
				self?.hostStack.clear()
				self?.opponentStack.clear()
				self?.manager.setState(.PointDual)
				return true
			}
			return false
		}
		
		let retry = { [weak self] in
			switch action.playerType {
			case .Host:
				self?.startHostStep()
			case .Opponent:
				self?.startOppoStep()
			}
		}
		
		if action.playerType == .Host && self.manager.getState() == .HostTurn {
			print("Host played card")
			let fb = processCard(action.playedHand!, self.hostStack, self.opponentStack)
			if fb == ActionFeedback.Accepted && !checkEqual() { self.manager.setState(.OpponentTurn) }
			else { retry() }
			return fb
		} else if action.playerType == .Opponent && self.manager.getState() == .OpponentTurn {
			print("Opponent played card")
			let fb = processCard(action.playedHand!, self.opponentStack, self.hostStack)
			if fb == ActionFeedback.Accepted && !checkEqual() { self.manager.setState(.HostTurn) }
			else { retry() }
			return fb
		} else {
			return ActionFeedback.Rejected(reason: "Cannot play hand during others turn")
		}
	}
	
	func startHostStep() {
		self.host?.requestAction() { (action: Action) -> Void in
			self.manager.registerAction(action)
		}
	}
	
	func startOppoStep() {
		self.opponent?.requestAction() { (action: Action) -> Void in
			self.manager.registerAction(action)
		}
	}
	
	//*****HELPER FUNCTION*****//
	
	private func deck_basic_condition() -> Bool {
		let oppohand = self.manager.opponent!.evaluateHand()
		let hosthand = self.manager.host!.evaluateHand()
		return oppohand.valid && hosthand.valid
	}
	
	private func vanish() {
		self.dualcount = 0
		self.manager.terminate()
		self.manager.host?.handCards = []
		self.manager.opponent?.handCards = []
	}
	
	private func getFirstWeaponCard(deck:Deck) throws -> WeaponCard {
		var index = deck.cardDeck.count - 1
		while index >= 0 {
			if let weapon = deck.cardDeck[index] as? WeaponCard {
				deck.cardDeck.removeAtIndex(index)
				return weapon
			} else {
				index--
			}
		}
		throw NSError(domain: "com.blade", code: 11, userInfo: [NSLocalizedDescriptionKey:"Weapon Card Not Found in current Deck"])
	}
	
	private func ifHandOnlyMagic(action:Action) -> Bool {
		var count = 0
		var total = 0
		switch action.playerType {
		case .Host:
			for card in self.host!.handCards {
				if card.sortIndex < 7 {
					count++
				}
				total++
			}
		case .Opponent:
			for card in self.opponent!.handCards {
				if card.sortIndex < 7 {
					count++
				}
				total++
			}
		}
		return count < 2 && total != count
	}
}