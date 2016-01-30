//
//  GameViewController.swift
//  Blade
//
//  Created by Peter Chen on 2015-11-24.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var hostHandLabel: UILabel!
	@IBOutlet weak var oppoHandLabel: UILabel!
	@IBOutlet weak var hostPointLabel: UILabel!
	@IBOutlet weak var oppoPointLabel: UILabel!
	@IBOutlet weak var hostHandTableView: UITableView!
	@IBOutlet weak var oppoHandTableView: UITableView!

	var playerA: Player?
	var playerB: Player?
	var gameManager: GameManager?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.hostHandTableView.dataSource = self
		self.hostHandTableView.delegate = self
		self.oppoHandTableView.dataSource = self
		self.oppoHandTableView.delegate = self

		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("enterNewState"), name: BladeNewStateNotfication, object: nil)

		let playerA = TestPlayer(name: "TEST A", type: .Host)
		let playerB = TestPlayer(name: "TEST B", type: .Opponent)
        let manager = GameManager(gameMode: .NoRestriction, host: playerA, opponent: playerB)
		playerA.manager = manager
		playerB.manager = manager

		self.playerA = playerA
		self.playerB = playerB
		self.gameManager = manager
        

		manager.start()
    }

	@objc private func enterNewState() {
		self.refreshUI()
	}

	// UI stuff

	private func refreshUI() {
		dispatch_async(dispatch_get_main_queue()) {
			self.hostHandLabel.text = self.playerA?.gameStatus?.hostDesk.cardStack.map({String(($0 as! WeaponCard).weaponNum)}).joinWithSeparator(" ")
			self.oppoHandLabel.text = self.playerB?.gameStatus?.oppoDesk.cardStack.map({String(($0 as! WeaponCard).weaponNum)}).joinWithSeparator(" ")
			self.hostPointLabel.text = String(self.playerA?.gameStatus?.hostDesk.point ?? -999)
			self.oppoPointLabel.text = String(self.playerB?.gameStatus?.oppoDesk.point ?? -999)

			self.hostHandTableView.reloadData()
			self.oppoHandTableView.reloadData()
		}
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch tableView {
		case self.hostHandTableView:
			print("TableView Host Count: \(self.playerA?.handCards.count)")
			return self.playerA?.handCards.count ?? 0
		case self.oppoHandTableView:
			print("TableView Oppo Count: \(self.playerB?.handCards.count)")
			return self.playerB?.handCards.count ?? 0
		default:
			return 0
		}
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch tableView {
		case self.hostHandTableView:
			let cell = tableView.dequeueReusableCellWithIdentifier("HostHandCell", forIndexPath: indexPath)
			cell.textLabel?.text = "\((self.playerA!.handCards[safe: indexPath.row] ?? NotCard()))"
			return cell
		case self.oppoHandTableView:
			let cell = tableView.dequeueReusableCellWithIdentifier("OppoHandCell", forIndexPath: indexPath)
			cell.textLabel?.text = "\((self.playerB!.handCards[safe: indexPath.row] ?? NotCard()))"
			return cell
		default:
			return UITableViewCell()
		}
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch tableView {
		case self.hostHandTableView:
			self.playerA?.playHand(index: indexPath.row)
			tableView.reloadData()
		case self.oppoHandTableView:
			self.playerB?.playHand(index: indexPath.row)
			tableView.reloadData()
		default:
			()
		}
	}
}
