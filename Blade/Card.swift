//
//  Card.swift
//  Blade
//
//  Created by Peter Chen on 2015-11-24.
//  Copyright © 2015 Peter Chen. All rights reserved.
//

import Foundation

enum CardType {
	case Weapon
	case Bolt
	case Mirror
	case NotCard
}

protocol Card: CustomStringConvertible {
	var cardType: CardType { get }
	var sortIndex: Int { get }
	var name: String { get }
}

protocol WeaponCard: Card {
	var weaponNum: Int { get }
}

class Eliot: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 1
	var sortIndex: Int = 0
	var name: String = "Eliot"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Fei: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 2
	var sortIndex: Int = 1
	var name: String = "Fei"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Alisa: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 3
	var sortIndex: Int = 2
	var name: String = "Alisa"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Jusis: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 4
	var sortIndex: Int = 3
	var name: String = "Jusis"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Machias: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 5
	var sortIndex: Int = 4
	var name: String = "Machias"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Gaius: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 6
	var sortIndex: Int = 5
	var name: String = "Gaius"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Laura: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 7
	var sortIndex: Int = 6
	var name: String = "Laura"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Bolt: Card {
	var cardType: CardType = .Bolt
	var weaponNum: Int? = nil
	var sortIndex: Int = 7
	var name: String = "Bolt"
	var description: String { get { return "B - \(self.name)" } }
}

class Mirror: Card {
	var cardType: CardType = .Mirror
	var weaponNum: Int? = nil
	var sortIndex: Int = 8
	var name: String = "Mirror"
	var description: String { get { return "M - \(self.name)" } }
}

class NotCard: Card {
	var cardType: CardType = .NotCard
	var weaponNum: Int? = nil
	var sortIndex: Int = 9
	var name: String = "Not a card"
	var description: String { get { return "Error Card" } }
}

func < (lhs: Card, rhs: Card) -> Bool {
	return lhs.sortIndex < rhs.sortIndex
}