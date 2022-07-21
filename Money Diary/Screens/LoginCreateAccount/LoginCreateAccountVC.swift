//
//  LoginCreateAccountVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 24/06/2022.
//

import UIKit
import ProgressHUD
import SPIndicator
import Firebase
import RealmSwift
import KeychainSwift

class LoginCreateAccountVC: UIViewController {

    var isLogInVC: Bool = true
    private let realm = try! Realm()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let keychain = KeychainSwift()

    private var signInText: String { isLogInVC ? "Sign In" : "Create Account" }
    private var email: String { emailTextField.text ?? "" }
    private var password: String { passwordTextField.text ?? "" }
    private var confirmPassword: String { confirmPasswordTextField.text ?? "" }
    private var isPasswordMatch: Bool {
        if isLogInVC {
            return !password.isEmpty
        } else {
            return password == confirmPassword && !password.isEmpty
        }
    }
    private var isValidEmail: Bool { Validator.isValidEmail(email) }

    @IBOutlet private var emailTextField: BaseTextField!
    @IBOutlet private var passwordTextField: PasswordTextField!
    @IBOutlet private var confirmPasswordTextField: PasswordTextField!
    @IBOutlet private var signInButton: BounceButton!
    @IBOutlet private var confirmPasswordView: UIView!
    @IBOutlet private var passwordMismatchLabel: UILabel!
    @IBOutlet private var signInToConfirmPasswordConstraint: NSLayoutConstraint!
    @IBOutlet private var resetPasswordButton: BounceButton!
    @IBOutlet private var signInToPasswordFieldConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = signInText
        navigationController?.navigationBar.titleTextAttributes = getAttributedStringDict(fontSize: 15.0, weight: .bold)

        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        confirmPasswordView.isHidden = isLogInVC
        signInButton.configuration?.attributedTitle = AttributedString(signInText, attributes: AttributeContainer(getAttributedStringDict(fontSize: 15.0, weight: .bold)))
        signInButton.isEnabled = false

        if !isLogInVC {
            passwordMismatchLabel.isHidden = true
            passwordTextField.returnKeyType = .next
            signInToPasswordFieldConstraint.isActive = false
            signInToConfirmPasswordConstraint.isActive = true
            resetPasswordButton.isHidden = true
        } else {
            signInToConfirmPasswordConstraint.isActive = false
            signInToPasswordFieldConstraint.isActive = true
            signInToPasswordFieldConstraint.constant = 40.0
            resetPasswordButton.isHidden = false
            bypass()
        }
    }

    @IBAction func signInTapped(_ sender: Any) {
        manageSignInCreateAccount()
    }

    @IBAction func resetPasswordTapped(_ sender: Any) {
        let passwordResetVC = ResetPasswordVC()
        let navController = UINavigationController(rootViewController: passwordResetVC)
        present(navController, animated: true)
    }
        
    @IBAction func textFieldDidChange(_ sender: Any) {
        if !isValidEmail && !isLogInVC {
            passwordMismatchLabel.isHidden = false
            signInButton.isEnabled = false
            passwordMismatchLabel.text = "Invalid email"
            return
        }
        
        if !isPasswordMatch {
            passwordMismatchLabel.isHidden = false
            signInButton.isEnabled = false
            passwordMismatchLabel.text = "Passwords do not match"
            return
        }
        passwordMismatchLabel.isHidden = true
        signInButton.isEnabled = true
    }

    private func manageSignInCreateAccount() {
        view.endEditing(true)
        if isLogInVC {
            handleSignIn()
        } else {
            handleCreateUser()
        }
    }

    private func bypass() {
        emailTextField.text = "test@email.com"
        passwordTextField.text = "111111"
        signInButton.isEnabled = true
    }

    func handleSignIn() {
        ProgressHUD.animationType = .lineSpinFade
        ProgressHUD.show()

        Task {
            await AuthManager.signIn(with: email, password: password, viewController: self)
            await FirestoreManager.getData()
            SPIndicator.present(title: "Success", message: "Signed in", preset: .done, haptic: .success)
            ProgressHUD.dismiss()
            showDashboard(isFromSplash: false)
        }
    }

    func handleCreateUser() {
        ProgressHUD.animationType = .horizontalCirclesPulse
        ProgressHUD.show()

        Task {
            await AuthManager.createUser(with: email, password: password, viewController: self)
            SPIndicator.present(title: "Success", message: "Account created", preset: .done, haptic: .success)
            ProgressHUD.dismiss()
            showDashboard(isFromSplash: false)
        }
    }
}

extension LoginCreateAccountVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            if isLogInVC {
                signInTapped(textField)
            } else {
                confirmPasswordTextField.becomeFirstResponder()
            }
        } else {
            manageSignInCreateAccount()
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
