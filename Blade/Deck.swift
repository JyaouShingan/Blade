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
    var magicDeck: [Card]
	
	init() {
		self.cardDeck = []
        self.magicDeck = []
		for _ in 0..<2 {
			self.cardDeck.append(Lightbringer())
			self.cardDeck.append(Apophis())
            self.magicDeck.append(Guardian())
		}
		for _ in 0..<3 {
			self.cardDeck.append(Arondight())
			self.cardDeck.append(Gungnir())
		}
		for _ in 0..<4 {
			self.cardDeck.append(Lævateinn())
			self.cardDeck.append(Frostmourne())
			self.cardDeck.append(Kusanagi())
            self.magicDeck.append(Speculum())
		}
		for _ in 0..<6 {
            self.magicDeck.append(Destruction())
		}
        
		self.shuffle()
		//for card in self.cardDeck {
		//	print(card)
		//}
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
    
    func nextMagic() ->Card? {
        let index = Int(arc4random_uniform(UInt32(self.magicDeck.count-1)))
        return self.magicDeck.removeAtIndex(index)
    }
}