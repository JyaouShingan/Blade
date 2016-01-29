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
    var graveyard: Card? = nil
	
	func addWeaponCard(card: Card) {
		self.cardStack.append(card)
		if let wCard = card as? WeaponCard {
			self.point += wCard.weaponNum
		}
	}
	
	func removeTopCard() {
		if let card = self.cardStack.popLast(), let wCard = card as? WeaponCard {
			self.point -= wCard.weaponNum
            self.graveyard? = card
		}
	}

	func clear() {
		self.cardStack.removeAll()
		self.point = 0
	}
}

class GameManager {
	
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
    var dualcount: Int?
	
	private var hostCardStack = DeskStack()
	private var oppoCardStack = DeskStack()
	
	init(gameMode: GameMode, host: Player, opponent: Player) {
		self.mode = gameMode
		self.state = .Hanging
		
		self.host = host
		self.opponent = opponent
        self.dualcount = 0

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
        
        for j in 0..<2 {
            if let card = self.deck.nextMagic() {
                if j % 2 == 0 {
                    self.host?.getHandcard(card)
                } else {
                    self.opponent?.getHandcard(card)
                }
            }
        }
        
        print(self.deck.cardDeck)
        self.deck.cardDeck += self.deck.magicDeck
        self.deck.shuffle()
        print(self.deck.cardDeck)
        
		for i in 0..<16 {
			if let card = self.deck.next() {
				if i % 2 == 0 {
					self.host?.getHandcard(card)
				} else {
					self.opponent?.getHandcard(card)
				}
			}
		}
        
        if(deck_basic_condition()) {
            print("HAND CONDITION PASSED") // DEBUG
            self.state = .PointDual
        }
        else {
            print("REFORGE HAPPANED BECAUSE OF HAND CONDITION ISNT SATISFIED") // DEBUG
            self.state = .Reforge
        }
	}
    
    private func reforge() {
        print("Reforge Happened")
        //TODO:simple implementation of restarting, should be more efficient
        host?.handCards = []
        opponent?.handCards = []
        self.state = .Start
    }
	
	private func pointDual() {
		do {
            //let hostCard = try self.getFirstWeaponCard()
			//let opponentCard = try self.getFirstWeaponCard()
            
            var hostCard:WeaponCard
            var opponentCard:WeaponCard
            
            repeat{
                hostCard = try self.getFirstWeaponCard()
                opponentCard = try self.getFirstWeaponCard()
                
                print("--PointDual--")
                print("Host: \(hostCard)")
                print("Opponent: \(opponentCard)")
                self.dualcount!++
                
                print("Dual Total Times: \(self.dualcount!)")
                
                if(self.dualcount == 4){
                    print("re-forge occurs")
                    //TODO:IMPLEMENT AFTER REFORGE IMPLEMENTATION
                }
            
            }while(hostCard.weaponNum == opponentCard.weaponNum)
            
            print("PointDual Finished")
            
			self.hostCardStack.addWeaponCard(hostCard)
			self.oppoCardStack.addWeaponCard(opponentCard)
            
			self.state = hostCard.weaponNum < opponentCard.weaponNum ? .HostTurn : .OpponentTurn
            
		} catch _ {
			self.state = .Error
            
		}
	}
	
	private func startHostStep() {
		self.host?.requestAction() { (action: Action) -> Void in
			self.registerAction(action)
		}
	}
	
	private func startOppoStep() {
		self.opponent?.requestAction() { (action: Action) -> Void in
			self.registerAction(action)
		}
	}
	
	private func processPlayHand(action: Action) -> ActionFeedback {
		let processCard = { (card: Card, actionStack: DeskStack, oppoStack: DeskStack) -> ActionFeedback in
			print("Played card: \(card)")
			switch card.cardType {
			case .Weapon:
				switch action.playerType {
                    
                //TODO:Implement Card 1, revive the last died weapon. Has to satisfy basic condition too
                    
				case .Host:
					if self.oppoCardStack.point - self.hostCardStack.point > (action.playedHand as! WeaponCard).weaponNum {
						return .Rejected(reason: "Must play a card larger than difference")
					}
				case .Opponent:
					if self.hostCardStack.point - self.oppoCardStack.point > (action.playedHand as! WeaponCard).weaponNum {
						return .Rejected(reason: "Must play a card larger than difference")
					}
				}
				actionStack.addWeaponCard(card)
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
                            if self.oppoCardStack.point > self.hostCardStack.point * 2 || self.hostCardStack.point == 0{
                                return .Rejected(reason: "Must play a card larger than difference")
                            }
                        case .Opponent:
                            if self.hostCardStack.point * 2 < self.oppoCardStack.point || self.oppoCardStack.point == 0{
                                return .Rejected(reason: "Must play a card larger than difference")
                            }
                        }
                        actionStack.addWeaponCard(copy)
                    }
                }
                
			default:
				()
			}
            //TODO:CHECK IF ONLY MAGIC CARD LEFT
			return .Accepted
		}

		let checkEqual = { [weak self] () -> Bool in
			if self?.hostCardStack.point == self?.oppoCardStack.point {
				print("Tie, clear desk and redraw")
				self?.hostCardStack.clear()
				self?.oppoCardStack.clear()
				self?.state = .PointDual
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
		
		if action.playerType == .Host && self.state == .HostTurn {
			print("Host played card")
			let fb = processCard(action.playedHand!, self.hostCardStack, self.oppoCardStack)
			if fb == ActionFeedback.Accepted && !checkEqual() { self.state = .OpponentTurn }
			else { retry() }
			return fb
		} else if action.playerType == .Opponent && self.state == .OpponentTurn {
			print("Opponent played card")
			let fb = processCard(action.playedHand!, self.oppoCardStack, self.hostCardStack)
			if fb == ActionFeedback.Accepted && !checkEqual() { self.state = .HostTurn }
			else { retry() }
			return fb
		} else {
			return ActionFeedback.Rejected(reason: "Cannot play hand during others turn")
		}
	}
	
	func registerAction(action: Action) {
		var feedback: ActionFeedback
		switch action.actionType {
		case .PlayHand:
			feedback = self.processPlayHand(action)
		case .OutOfCard:
			self.state = .End
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
    
	// MARK:- Helper
	
	private func getFirstWeaponCard() throws -> WeaponCard {
		var index = self.deck.cardDeck.count - 1
		while index >= 0 {
			if let weapon = self.deck.cardDeck[index] as? WeaponCard {
				self.deck.cardDeck.removeAtIndex(index)
				return weapon
			} else {
				index--
			}
		}
		throw NSError(domain: "com.blade", code: 11, userInfo: [NSLocalizedDescriptionKey:"Weapon Card Not Found in current Deck"])
	}
    
    private func deck_basic_condition() -> Bool {
        let oppohand = opponent!.evaluateHand()
        let hosthand = host!.evaluateHand()
        return oppohand.valid && hosthand.valid
    }
}