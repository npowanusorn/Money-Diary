//
//  RecordDetailsVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 21/06/2022.
//

import UIKit

class RecordDetailsVC: UIViewController {

    var selectedRecord: Record!

    @IBOutlet private var headerMoneyLabel: UILabel!
    @IBOutlet private var categoryLabel: UILabel!
    @IBOutlet private var noteLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var walletLabel: UILabel!

    private let walletManager = WalletManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        guard selectedRecord != nil else { return }
        headerMoneyLabel.text = selectedRecord.amount.toCurrencyString()
        headerMoneyLabel.textColor = selectedRecord.isExpense ? .systemRed : .systemBlue
        categoryLabel.text = "category"
        noteLabel.text = selectedRecord.notes
        dateLabel.text = selectedRecord.date.toString(withFormat: .long)
        walletLabel.text = walletManager.getWallet(at: selectedRecord.walletIndex).name

        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRecord))
        rightBarButtonItem.tintColor = globalTintColor
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @IBAction func deleteTapped(_ sender: Any) {
        if walletManager.removeRecordFromWallet(recordToRemove: selectedRecord) {
            Log.info("remove record success")
        } else {
            Log.error("error removing record")
        }
    }

    @objc func editRecord() {

    }

}
