//
//  ChangeEmailVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 27/06/2022.
//

import UIKit
import ProgressHUD
import Firebase
import KeychainSwift
import SPIndicator

class ChangeEmailVC: UIViewController {

    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var passwordLabel: UILabel!
    @IBOutlet private var passwordTextField: PasswordTextField!
    @IBOutlet private var emailTextField: BaseTextField!
    @IBOutlet private var validationLabel: UILabel!
    @IBOutlet private var changeEmailButton: BounceButton!

    private var password: String { return passwordTextField.text ?? "" }
    private var email: String { return emailTextField.text ?? "" }
    private var shouldEnableButton: Bool { Validator.isValidEmail(email) && password.count >= 6 }
    private var errorMessage: String? = nil
    private var isNewEmailDifferent: Bool {
        guard let oldEmail = keychain.get(K.KeychainKeys.emailKey) else { return true }
        return email != oldEmail
    }

    private let keychain = KeychainSwift()
    private let currentUser = Auth.auth().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedKeys.title

        emailLabel.text = LocalizedKeys.newEmail
        passwordLabel.text = LocalizedKeys.password

        passwordTextField.delegate = self
        emailTextField.delegate = self

        passwordTextField.layer.borderColor = nil
        emailTextField.layer.borderColor = nil

        changeEmailButton.isEnabled = false
        validationLabel.isHidden = true
        validationLabel.text = LocalizedKeys.invalidEmail
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if sender == emailTextField, !email.isEmpty {
            validationLabel.text = LocalizedKeys.invalidEmail
            validationLabel.isHidden = Validator.isValidEmail(email)
        }
        changeEmailButton.isEnabled = shouldEnableButton
    }


    @IBAction func changeEmailButtonTapped(_ sender: UIButton) {
        Task { await handleChangeEmail() }
    }
    
    private func handleChangeEmail() async {
        ProgressHUD.animationType = .horizontalCirclesPulse
        ProgressHUD.show()

        guard let oldEmail = keychain.get(K.KeychainKeys.emailKey) else { return }
        let credential = EmailAuthProvider.credential(withEmail: oldEmail, password: password)

        do {
            try await reauthenticateUser(with: credential)
            Log.info("REAUTHENTICATED")
            try await changeEmail()
            Log.info("EMAIL CHANGED")
            ProgressHUD.dismiss()
            SPIndicator.present(title: "Success", message: "Email changed", preset: .done, haptic: .success, from: .top, completion: nil)
            keychain.set(email, forKey: K.KeychainKeys.emailKey)
            main { self.navigationController?.popViewController(animated: true) }
        } catch {
            ProgressHUD.dismiss()
            Log.error("ERROR : \(error.localizedDescription)")
            let alert = UIAlertController.showErrorAlert(message: error.localizedDescription)
            main { self.present(alert, animated: true) }
        }
    }

    @objc
    private func dismissVC() {
        dismiss(animated: true)
    }

    private func reauthenticateUser(with credential: AuthCredential) async throws {
        do { try await currentUser?.reauthenticate(with: credential) }
    }

    private func changeEmail() async throws {
        do { try await currentUser?.updateEmail(to: email) }
    }
}

extension ChangeEmailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let textField = textField as? BaseTextField else { return }
        textField.setWhiteBorder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? BaseTextField else { return }
        textField.removeBorder()
    }
}

private extension ChangeEmailVC {
    enum LocalizedKeys {
        static let title = "change_email_title".localized
        static let password = "change_email_password".localized
        static let newEmail = "change_email_new_email".localized
        static let button = "change_email_button".localized
        static let invalidEmail = "change_email_invalid_email".localized
    }
}
