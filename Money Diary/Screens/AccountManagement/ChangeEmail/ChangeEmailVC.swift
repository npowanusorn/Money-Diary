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

    @IBOutlet private var passwordTextField: PasswordTextField!
    @IBOutlet private var emailTextField: BaseTextField!
    @IBOutlet private var confirmEmailTextField: BaseTextField!
    @IBOutlet private var validationLabel: UILabel!
    @IBOutlet private var confirmValidationLabel: UILabel!
    @IBOutlet private var changeEmailButton: BounceButton!

    private var password: String { return passwordTextField.text ?? "" }
    private var email: String { return emailTextField.text ?? "" }
    private var confirmEmail: String { return confirmEmailTextField.text ?? "" }
    private var shouldEnableButton: Bool { Validator.isValidEmail(email) && email == confirmEmail && isNewEmailDifferent }
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

        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = rightBarButton

        passwordTextField.delegate = self
        emailTextField.delegate = self
        confirmEmailTextField.delegate = self

        passwordTextField.layer.borderColor = nil
        emailTextField.layer.borderColor = nil
        confirmEmailTextField.layer.borderColor = nil

        changeEmailButton.isEnabled = false
        validationLabel.isHidden = true
        confirmValidationLabel.isHidden = true
        validationLabel.text = LocalizedKeys.invalidEmail
        confirmValidationLabel.text = LocalizedKeys.emailNotMatch
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if sender == emailTextField, !email.isEmpty {
            validationLabel.text = LocalizedKeys.invalidEmail
            validationLabel.isHidden = Validator.isValidEmail(email)
        } else if sender == confirmEmailTextField, !confirmEmail.isEmpty {
            confirmValidationLabel.isHidden = email == confirmEmail
        }
        if !isNewEmailDifferent {
            validationLabel.text = LocalizedKeys.sameEmail
            validationLabel.isHidden = false
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
            dismiss(animated: true)
            keychain.set(email, forKey: K.KeychainKeys.emailKey)
        } catch {
            ProgressHUD.dismiss()
            Log.error("ERROR : \(error.localizedDescription)")
            let alert = UIAlertController.showErrorAlert(message: error.localizedDescription)
            present(alert, animated: true)
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
    private func textFieldShouldReturn(_ textField: UITextField) async -> Bool {
        if textField == passwordTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            confirmEmailTextField.becomeFirstResponder()
        } else {
            if shouldEnableButton { await handleChangeEmail() }
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.white.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = nil
        textField.layer.borderWidth = 0.0
    }
}

private extension ChangeEmailVC {
    enum LocalizedKeys {
        static let title = "change_email_title".localized
        static let password = "change_email_password".localized
        static let newEmail = "change_email_new_email".localized
        static let confirmEmail = "change_email_confirm_email".localized
        static let button = "change_email_button".localized
        static let invalidEmail = "change_email_invalid_email".localized
        static let emailNotMatch = "change_email_email_not_match".localized
        static let sameEmail = "change_email_same_email".localized
    }
}
