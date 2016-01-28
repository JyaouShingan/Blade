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
    case Magic
	case NotCard
}

enum MagicType {
    case Bolt
    case Mirror
    case Bless
}

protocol Card: class, CustomStringConvertible {
	var cardType: CardType { get }
	var sortIndex: Int { get }
	var name: String { get }
}

protocol WeaponCard: Card {
	var weaponNum: Int { get set }
}

protocol MagicCard: Card {
    var weaponNum: Int? { get }
    var magicType: MagicType { get }
}

class Lightbringer: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 1
	var sortIndex: Int = 0
	var name: String = "Lightbringer"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Arondight: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 2
	var sortIndex: Int = 1
	var name: String = "Arondight"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Lævateinn: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 3
	var sortIndex: Int = 2
	var name: String = "Lævateinn"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Kusanagi: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 4
	var sortIndex: Int = 3
	var name: String = "Kusanagi"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Frostmourne: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 5
	var sortIndex: Int = 4
	var name: String = "Frostmourne"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Gungnir: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 6
	var sortIndex: Int = 5
	var name: String = "Gungnir"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Apophis: WeaponCard {
	var cardType: CardType = .Weapon
	var weaponNum: Int = 7
	var sortIndex: Int = 6
	var name: String = "Apophis"
	var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class GuardianCopy: WeaponCard {
    var cardType: CardType = .Weapon
    var weaponNum: Int = 0
    var sortIndex: Int = 9999
    var name: String = "GuardianCopy"
    var description: String { get { return "\(self.weaponNum) - \(self.name)" } }
}

class Destruction: MagicCard {
	var cardType: CardType = .Magic
    var magicType: MagicType = .Bolt
	var weaponNum: Int? = nil
	var sortIndex: Int = 7
	var name: String = "Destruction"
	var description: String { get { return "B - \(self.name)" } }
}

class Speculum: MagicCard {
	var cardType: CardType = .Magic
    var magicType: MagicType = .Mirror
	var weaponNum: Int? = nil
	var sortIndex: Int = 8
	var name: String = "Speculum"
	var description: String { get { return "M - \(self.name)" } }
}

class Guardian: MagicCard {
    var cardType: CardType = .Magic
    var magicType: MagicType = .Bless
    var weaponNum: Int? = nil
    var sortIndex: Int = 9
    var name: String = "Guardian"
    var description: String { get { return "G - \(self.name)" } }
}

class NotCard: Card {
	var cardType: CardType = .NotCard
	var weaponNum: Int = 0
	var sortIndex: Int = 10
	var name: String = "Not a card"
	var description: String { get { return "Error Card" } }
}

func < (lhs: Card, rhs: Card) -> Bool {
	return lhs.sortIndex < rhs.sortIndex
}