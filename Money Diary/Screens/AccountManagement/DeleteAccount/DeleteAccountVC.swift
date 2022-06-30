//
//  DeleteAccountVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 28/06/2022.
//

import UIKit
import Firebase
import ProgressHUD
import KeychainSwift

class DeleteAccountVC: UIViewController {

    @IBOutlet private var passwordLabel: UILabel!
    @IBOutlet private var passwordTextField: PasswordTextField!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var deleteAccountButton: BounceButton!

    private let keychain = KeychainSwift()
    private let currentUser = Auth.auth().currentUser

    private var password: String { passwordTextField.text ?? "" }
    private var shouldEnableButton: Bool { password.count >= 6 }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedKeys.title
        passwordLabel.text = LocalizedKeys.confirmPassword
        descriptionLabel.text = LocalizedKeys.description
        deleteAccountButton.setTitle(LocalizedKeys.button, for: .normal)
        deleteAccountButton.isEnabled = false

        passwordTextField.delegate = self
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        deleteAccountButton.isEnabled = shouldEnableButton
    }

    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        let alert = UIAlertController.showDeleteConfirmationAlert(with: LocalizedKeys.alertTitle, message: LocalizedKeys.alertMessage) {
            Task { await self.handleDeletion() }
        }
        present(alert, animated: true)
    }

    private func handleDeletion() async {
        ProgressHUD.animationType = .horizontalCirclesPulse
        ProgressHUD.show()

        guard let email = keychain.get(K.KeychainKeys.emailKey) else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        do {
            Log.info("**** REAUTHENTICATING ****")
            try await currentUser?.reauthenticate(with: credential)
            Log.info("**** REAUTHENTICATED - STARTING ACCOUNT DELETION ****")
            try await currentUser?.delete()
            Log.info("**** DELETION COMPLETE ****")
            clearAllData()
            ProgressHUD.dismiss()
            main { self.navigationController?.popToRootViewController(animated: true) }
        } catch {
            Log.error("ERROR DELETING: \(error.localizedDescription)")
            let alert = UIAlertController.showErrorAlert(message: error.localizedDescription)
            main { self.present(alert, animated: true) }
        }
    }
}

extension DeleteAccountVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        passwordTextField.setWhiteBorder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        passwordTextField.removeBorder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

private extension DeleteAccountVC {
    enum LocalizedKeys {
        static let title = "delete_account_title".localized
        static let confirmPassword = "delete_account_confirm_password".localized
        static let description = "delete_account_description".localized
        static let button = "delete_account_button".localized
        static let alertTitle = "delete_account_alert_title".localized
        static let alertMessage = "delete_account_alert_message".localized
    }
}