//
//  LoginCreateAccountVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 24/06/2022.
//

import UIKit

class LoginCreateAccountVC: UIViewController {

    var isLogInVC: Bool = true

    private var signInText: String {
        return isLogInVC ? "Sign In" : "Create Account"
    }

    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var confirmPasswordTextField: UITextField!
    @IBOutlet private var signInButton: UIButton!
    @IBOutlet private var confirmPasswordView: UIView!
    @IBOutlet private var passwordMismatchLabel: UILabel!
    @IBOutlet private var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = signInText
        navigationController?.navigationBar.titleTextAttributes = getAttributedString(fontSize: 15.0, weight: .bold)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        confirmPasswordView.isHidden = isLogInVC
        signInButton.configuration?.attributedTitle = AttributedString(signInText, attributes: AttributeContainer(getAttributedString(fontSize: 15.0, weight: .bold)))

        if !isLogInVC {
            confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            passwordMismatchLabel.isHidden = true
            signInButton.isEnabled = false
            passwordTextField.returnKeyType = .next
        }
    }

    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if signInButton.transform.isIdentity {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut) {
                    self.signInButton.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height)
                    self.view.frame.origin.y -= 20
                }
            }
        }
    }

    @objc
    func keyboardWillHide(_ notification: Notification) {
        if !signInButton.transform.isIdentity {
            signInButton.transform = CGAffineTransform.identity
            self.view.frame.origin.y += 20
        }
    }

    @IBAction func signInTapped(_ sender: Any) {
        let dashboardVC = DashboardVC()
        navigationController?.pushViewController(dashboardVC, animated: true)
    }

    @objc
    func textFieldDidChange(_ textField: UITextField) {
        if confirmPasswordTextField.text != passwordTextField.text {
            passwordMismatchLabel.isHidden = false
            signInButton.isEnabled = false
        } else {
            passwordMismatchLabel.isHidden = true
            signInButton.isEnabled = true
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
