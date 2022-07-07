//
//  AddWalletVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 18/06/2022.
//

import UIKit
import RealmSwift

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
            let alert = UIAlertController.showUnsavedChangesSheet {
                self.dismiss(animated: true)
            }
            present(alert, animated: true)
        }
    }

    @objc
    func addWallet() {
        let newWallet = Wallet(name: name, balance: amount)
        WalletManager.shared.addWallet(newWallet: newWallet)
        delegate?.didAddWallet(wallet: newWallet)

        if UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.localAccount) {
            do {
                Log.info("**** WRITING TO REALM ****")
                let realm = try Realm()
                try realm.write {
                    realm.add(newWallet)
                }
            } catch {
                Log.error("REALM WRITE ERROR: \(error)")
            }
        } else {
            Task { await FirestoreManager.writeData(forWallet: newWallet) }
        }

        dismiss(animated: true)
    }

}

extension AddWalletVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if canDismissScreen {
            return true
        } else {
            let alert = UIAlertController.showUnsavedChangesSheet {
                self.dismiss(animated: true)
            }
            present(alert, animated: true)
            return false
        }
    }
}
