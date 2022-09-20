//
//  ChangePasswordVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 28/06/2022.
//

import UIKit
import Firebase
import KeychainSwift
import ProgressHUD
import SPIndicator

class ChangePasswordVC: UIViewController {

    @IBOutlet var oldPasswordTextField: PasswordTextField!
    @IBOutlet var newPasswordTextField: PasswordTextField!
    @IBOutlet var confirmPasswordTextField: PasswordTextField!
    @IBOutlet var topValidationLabel: UILabel!
    @IBOutlet var bottomValidationLabel: UILabel!
    @IBOutlet var changePasswordButton: BounceButton!

    private var oldPassword: String { return oldPasswordTextField.text ?? "" }
    private var newPassword: String { return newPasswordTextField.text ?? "" }
    private var confirmPassword: String { return confirmPasswordTextField.text ?? "" }
    private var shouldEnableButton: Bool { return newPassword == confirmPassword && newPassword.count >= 6 }

    private let currentUser = Auth.auth().currentUser
    private let keychain = KeychainSwift()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedKeys.title

        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        changePasswordButton.isEnabled = false
        topValidationLabel.isHidden = true
        bottomValidationLabel.isHidden = true
        topValidationLabel.text = LocalizedKeys.minimumLength
        bottomValidationLabel.text = LocalizedKeys.mismatch
    }

    @objc
    private func dismissVC() {
        self.dismiss(animated: true)
    }

    @IBAction func changePasswordTapped(_ sender: UIButton) {
        Task { await changePasswordTask() }
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if sender == newPasswordTextField {
            topValidationLabel.isHidden = newPassword.isEmpty || newPassword.count >= 6
        } else if sender == confirmPasswordTextField {
            bottomValidationLabel.isHidden = confirmPassword.isEmpty || newPassword == confirmPassword
        }
        changePasswordButton.isEnabled = shouldEnableButton
    }

    private func changePasswordTask() async {
        ProgressHUD.animationType = .horizontalCirclesPulse
        ProgressHUD.show()

        guard let email = keychain.get(K.KeychainKeys.emailKey) else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

        do {
            try await reauthenticateUser(with: credential)
            Log.info("CHANGE PASSWORD: REAUTHENTICATED")
            try await changePassword()
            Log.info("CHANGE PASSWORD: CHANGED")
            ProgressHUD.dismiss()
            SPIndicator.present(title: "Success", message: "Password changed", preset: .done, haptic: .success, from: .top, completion: nil)
            keychain.set(newPassword, forKey: K.KeychainKeys.passwordKey)
            main { _ = self.navigationController?.popViewController(animated: true) }
        } catch {
            ProgressHUD.dismiss()
            Log.error("ERROR : \(error.localizedDescription)")
            let alert = UIAlertController.showErrorAlert(message: error.localizedDescription)
            main { self.present(alert, animated: true) }
        }
    }

    private func reauthenticateUser(with credential: AuthCredential) async throws {
        do { try await currentUser?.reauthenticate(with: credential) }
    }

    private func changePassword() async throws {
        do { try await currentUser?.updatePassword(to: newPassword) }
    }

    
}

extension ChangePasswordVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let textField = textField as? BaseTextField else { return }
        textField.setWhiteBorder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? BaseTextField else { return }
        textField.removeBorder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

private extension ChangePasswordVC {
    enum LocalizedKeys {
        static let title = "change_password_title".localized
        static let oldPassword = "change_password_old_password".localized
        static let newPassword = "change_password_new_password".localized
        static let confirmPassword = "change_password_confirm_password".localized
        static let minimumLength = "change_password_minimum_length".localized
        static let mismatch = "change_password_password_mismatch".localized
        static let button = "change_password_button".localized
    }
}
