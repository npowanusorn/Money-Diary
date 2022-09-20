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

    @IBOutlet private var walletNameTextField: UITextField!
    @IBOutlet private var amountTextField: UITextField!
    @IBOutlet private weak var addButton: BounceButton!
    
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
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        rightBarButtonItem.tintColor = globalTintColor

        addButton.isEnabled = false

        amountTextField.delegate = self

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if sender == walletNameTextField {
            name = sender.text ?? ""
        } else {
            amountString = sender.text ?? ""
        }
        addButton.isEnabled = walletNameTextField.hasText && amountTextField.hasText
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        let walletType = AppCache.shared.walletType ?? .unknown
        let newWallet = Wallet(name: name, balance: amount, type: walletType)
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
//
//    @objc func keyboardWillShow(notification: Notification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            addButton.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height)
//        }
//    }
//
//    @objc func keyboardWillHide(notification: Notification) {
//        if addButton.transform.ty != 0 {
//            addButton.transform = CGAffineTransform(translationX: 0, y: 0)
//        }
//    }

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

extension AddWalletVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return updatedText.isValidDouble || updatedText.isEmpty
        }
        return false
    }
}
