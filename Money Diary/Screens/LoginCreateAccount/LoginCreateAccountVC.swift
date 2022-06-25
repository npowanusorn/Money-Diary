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

class LoginCreateAccountVC: UIViewController {

    var isLogInVC: Bool = true

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
    @IBOutlet private var signInButton: UIButton!
    @IBOutlet private var confirmPasswordView: UIView!
    @IBOutlet private var passwordMismatchLabel: UILabel!
    @IBOutlet private var signInToPasswordFieldConstraint: NSLayoutConstraint!
    @IBOutlet private var signInToConfirmPasswordConstraint: NSLayoutConstraint!
    @IBOutlet var resetPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = signInText
        navigationController?.navigationBar.titleTextAttributes = getAttributedString(fontSize: 15.0, weight: .bold)

        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        confirmPasswordView.isHidden = isLogInVC
        signInButton.configuration?.attributedTitle = AttributedString(signInText, attributes: AttributeContainer(getAttributedString(fontSize: 15.0, weight: .bold)))
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
        }
    }

    @IBAction func signInTapped(_ sender: Any) {
        ProgressHUD.animationType = .circleSpinFade
        ProgressHUD.show()
        if isLogInVC {
            handleSignIn()
        } else {
            handleCreateUser()
        }
    }

    @IBAction func resetPasswordTapped(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                Log.error("ERROR RESET PASSWORD: \(error.localizedDescription)")
                let alert = UIAlertController.showErrorAlert(with: error.localizedDescription)
                strongSelf.present(alert, animated: true)
            }
            strongSelf.present(UIAlertController.showOkAlert(with: "Email sent", message: "Check your email to reset your password"), animated: true)
        }
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
    
    func handleSignIn() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                Log.error("SIGN IN FAILED: \(error.localizedDescription)")
                let alert = UIAlertController.showDismissAlert(with: "Error", message: error.localizedDescription)
                strongSelf.present(alert, animated: true)
                ProgressHUD.dismiss()
                return
            }
            ProgressHUD.dismiss()
            SPIndicator.present(title: "Success", message: "Signed in", preset: .done, haptic: .success)
            let dashboardVC = DashboardVC()
            strongSelf.navigationController?.pushViewController(dashboardVC, animated: true)
        }
    }
    
    func handleCreateUser() {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                Log.error("CREATE ACCOUNT FAILED: \(error.localizedDescription)")
                let alert = UIAlertController.showDismissAlert(with: "Error", message: error.localizedDescription)
                strongSelf.present(alert, animated: true)
                ProgressHUD.dismiss()
                return
            }
            ProgressHUD.dismiss()
            SPIndicator.present(title: "Success", message: "Created account", preset: .done, haptic: .success)
            let dashboardVC = DashboardVC()
            strongSelf.navigationController?.pushViewController(dashboardVC, animated: true)
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
            signInTapped(textField)
        }
        return false
    }

}
