//
//  Deck.swift
//  Blade
//
//  Created by Peter Chen on 2015-11-24.
//  Copyright © 2015 Peter Chen. All rights reserved.
//

import Foundation

class Deck {
	var cardDeck: [Card]
	
	init() {
		self.cardDeck = []
		for _ in 0..<2 {
			self.cardDeck.append(Eliot())
			self.cardDeck.append(Laura())
		}
		for _ in 0..<3 {
			self.cardDeck.append(Fei())
			self.cardDeck.append(Gaius())
		}
		for _ in 0..<4 {
			self.cardDeck.append(Alisa())
			self.cardDeck.append(Jusis())
			self.cardDeck.append(Machias())
			self.cardDeck.append(Mirror())
		}
		for _ in 0..<6 {
			self.cardDeck.append(Bolt())
		}
		self.shuffle()
		for card in self.cardDeck {
			print(card)
		}
	}
	
	func shuffle() {
		let count = self.cardDeck.count
		let shuffleNum = 100
		for _ in 0..<shuffleNum {
			for index in 0..<count {
				let randi = Int(arc4random()) % count
				if index != randi {
					swap(&self.cardDeck[index], &self.cardDeck[randi])
				}
			}
			self.cardDeck = self.cardDeck.reverse()
		}
	}
	
	func next() -> Card? {
		return self.cardDeck.popLast()
	}
}