//
//  RecordDetailsVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 21/06/2022.
//

import UIKit
import SPIndicator

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
        noteLabel.text = selectedRecord.note
        dateLabel.text = selectedRecord.date.toString(withFormat: .long)
        walletLabel.text = selectedRecord.wallet.name

        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRecord))
        rightBarButtonItem.tintColor = globalTintColor
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @IBAction func deleteTapped(_ sender: Any) {
        let wallet = selectedRecord.wallet
        if wallet.removeRecord(recordToRemove: selectedRecord) {
            navigationController?.popViewController(animated: true)
            SPIndicator.present(title: "Success", message: "Record removed", preset: .done, haptic: .success, from: .top, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Error deleting record", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default)
            alertController.addAction(action)
            present(alertController, animated: true)
        }
    }

    @objc func editRecord() {

    }

}
