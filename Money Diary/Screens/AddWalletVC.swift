//
//  AddWalletVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 18/06/2022.
//

import UIKit

protocol AddedWalletDelegate {
    func didAddWallet(wallet: Wallet)
}

class AddWalletVC: UIViewController {

    @IBOutlet var walletNameTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!

    private var name = ""
    private var amountString = "" {
        didSet { amount = Double(amountString) ?? 0.0 }
    }
    private var amount: Double = 0.0
    private var canDismiss: Bool {
        return name.isEmpty && amountString.isEmpty
    }

    var delegate: AddedWalletDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Wallet"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)]
        let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissView))
        let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addWallet))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        rightBarButtonItem.isEnabled = false
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if sender == walletNameTextField {
            name = sender.text ?? ""
        } else {
            amountString = sender.text ?? ""
        }
        navigationItem.rightBarButtonItem?.isEnabled = walletNameTextField.hasText && amountTextField.hasText
    }

    @objc
    func dismissView() {
        if canDismiss {
            dismiss(animated: true)
        } else {
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let primaryAction = UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
                self.dismiss(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertVC.addAction(primaryAction)
            alertVC.addAction(cancelAction)
            present(alertVC, animated: true)
        }
    }

    @objc
    func addWallet() {
        let newWallet = Wallet(name: name, balance: amount, transactions: [])
        WalletManager.shared.addWallet(newWallet: newWallet)
        delegate?.didAddWallet(wallet: newWallet)
        dismiss(animated: true)
    }

}
