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
    private var canDismissScreen: Bool {
        return name.isEmpty && amountString.isEmpty
    }

    var delegate: AddedWalletDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Wallet"
        self.navigationController?.presentationController?.delegate = self
        let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissView))
        let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addWallet))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        rightBarButtonItem.isEnabled = false
        rightBarButtonItem.tintColor = globalTintColor
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
        if canDismissScreen {
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
        let newWallet = Wallet(name: name, balance: amount)
        WalletManager.shared.addWallet(newWallet: newWallet)
        delegate?.didAddWallet(wallet: newWallet)
        dismiss(animated: true)
    }

}

extension AddWalletVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if canDismissScreen {
            return true
        } else {
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let primaryAction = UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
                self.dismiss(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertVC.addAction(primaryAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true)
            return false
        }
    }
}
