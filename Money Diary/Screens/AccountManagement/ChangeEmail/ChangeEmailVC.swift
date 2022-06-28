//
//  ChangeEmailVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 27/06/2022.
//

import UIKit

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
    private var shouldEnableButton: Bool { Validator.isValidEmail(email) && email == confirmEmail }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Change Email"

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
        validationLabel.text = "Invalid Email"
        confirmValidationLabel.text = "Email does not match"
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if sender == emailTextField, !email.isEmpty {
            validationLabel.isHidden = Validator.isValidEmail(email)
        } else if sender == confirmEmailTextField, !confirmEmail.isEmpty {
            confirmValidationLabel.isHidden = email == confirmEmail
        }
        changeEmailButton.isEnabled = shouldEnableButton
    }

    @IBAction func changeEmailButtonTapped(_ sender: UIButton) {
        handleChangeEmail()
    }
    
    private func handleChangeEmail() {
        Log.info("CHANGE EMAIL")
    }

    @objc
    private func dismissVC() {
        dismiss(animated: true)
    }

}

extension ChangeEmailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            confirmEmailTextField.becomeFirstResponder()
        } else {
            if shouldEnableButton { handleChangeEmail() }
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
