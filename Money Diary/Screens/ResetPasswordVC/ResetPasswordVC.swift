//
//  ResetPasswordVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-26.
//

import UIKit
import Firebase
import ProgressHUD

class ResetPasswordVC: UIViewController {

    @IBOutlet private var emailTextField: BaseTextField!
    @IBOutlet private var validationLabel: UILabel!
    @IBOutlet private var resetPasswordButton: BounceButton!
    
    private var email: String { emailTextField.text ?? "" }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedKeys.title.localized
        navigationController?.navigationBar.titleTextAttributes = getAttributedStringDict(fontSize: 15.0, weight: .bold)
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailTextField.delegate = self
        validationLabel.isHidden = true
        
        resetPasswordButton.isEnabled = false
    }
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        ProgressHUD.animationType = .lineSpinFade
        ProgressHUD.show()
        handleResetPassword()
    }
    
    private func handleResetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.handleError(error: error)
            } else {
                strongSelf.handleSuccess()
            }
            ProgressHUD.dismiss()
        }
    }
        
    @objc
    private func dismissVC() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        if Validator.isValidEmail(email) {
            resetPasswordButton.isEnabled = true
            validationLabel.isHidden = true
        } else {
            resetPasswordButton.isEnabled = false
            validationLabel.isHidden = false
        }
    }
    
    private func handleError(error: Error) {
        Log.error("ERROR RESET PASSWORD: \(error.localizedDescription)")
        let alert = UIAlertController.showErrorAlert(message: error.localizedDescription)
        present(alert, animated: true)
    }
    
    private func handleSuccess() {
        let alert = UIAlertController.showOkAlert(
            with: LocalizedKeys.alertTitle.localized,
            message: LocalizedKeys.alertMessage.localized
        ) {
            self.dismissVC()
        }
        present(alert, animated: true)
    }

}

extension ResetPasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleResetPassword()
        return false
    }
}

private enum LocalizedKeys {
    static let title = "reset_password_title"
    static let alertTitle = "reset_password_alert_title"
    static let alertMessage = "reset_password_alert_message"
}
