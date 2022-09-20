//
//  LoginCreateAccountVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 23/06/2022.
//

import UIKit
import SPIndicator
import GoogleSignIn

class WelcomeVC: UIViewController {
    
    var error: NSError? = nil
    var shouldAnimateElements = false

    @IBOutlet private var optionsView: UIView!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var googleButton: BounceButton!
    @IBOutlet private var emailButton: BounceButton!
    @IBOutlet private var createAccountButton: BounceButton!
    @IBOutlet private var continueWithoutAccountButton: BounceButton!
    @IBOutlet private var headerLabelVerticalConstraint: NSLayoutConstraint!
    @IBOutlet private var termsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        googleButton.setTitle(LocalizedKeys.signInWithGoogle.localized, for: .normal)
        emailButton.setTitle(LocalizedKeys.signInWithEmail.localized, for: .normal)
        createAccountButton.setTitle(LocalizedKeys.createAccount.localized, for: .normal)

        if let error = error {
            FirebaseErrorManager.handleError(error: error, viewController: self)
        }

        googleButton.setImage(UIImage(named: "Google")?.resize(newWidth: 30.0), for: .normal)
        googleButton.configuration?.imagePadding = 20.0
        
        navigationItem.setHidesBackButton(true, animated: true)
        Log.info("SHOULDANIMATE: \(shouldAnimateElements)")
        if shouldAnimateElements { animateElements() }
        else { positionHeaderLabel() }
        
        let termsText = LocalizedKeys.createAccountSubtext.localized + LocalizedKeys.terms.localized
        termsLabel.text = termsText
        let attributedString = NSMutableAttributedString(string: termsText)
        let range = (termsText as NSString).range(of: LocalizedKeys.terms.localized)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: range)
        termsLabel.attributedText = attributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(termsTextTapped))
        termsLabel.addGestureRecognizer(tapGesture)

        continueWithoutAccountButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }

    @IBAction func signInWithGoogleTapped(_ sender: Any) {
        Log.info("SIGN IN WITH GOOGLE")
        let alert = UIAlertController.showDismissAlert(with: "Error", message: "Not Implemented")
        present(alert, animated: true)
    }

    @IBAction func signInWithEmailTapped(_ sender: Any) {
        Log.info("SIGN IN WITH EMAIL")
        goToNext(isLogIn: true)
    }

    @IBAction func createAccountTapped(_ sender: Any) {
        Log.info("create account")
        goToNext(isLogIn: false)
    }

    @IBAction func continueWithoutAccountTapped(_ sender: BounceButton) {
        let alert = UIAlertController.showAlert(with: "Continue without account", message: "Your data will only be available on this device", style: .alert, primaryActionName: "Continue", primaryActionStyle: .default, secondaryActionName: "Cancel", secondaryActionStyle: .cancel, primaryCompletion: {
            self.handleContinueWithAccount()
        }, secondaryCompletion: nil)
        present(alert, animated: true)
    }
    
    private func handleContinueWithAccount() {
        Log.info("CONTINUE WITHOUT ACCOUNT")
        UserDefaults.standard.set(true, forKey: "localAccount")
        let dashboardVC = DashboardVC()
        navigationController?.pushViewController(dashboardVC, animated: true)
    }
    
    private func goToNext(isLogIn: Bool) {
        let loginCreateAccountVC = LoginCreateAccountVC()
        loginCreateAccountVC.isLogInVC = isLogIn
        let back = UIBarButtonItem()
        back.title = ""
        back.tintColor = .label
        navigationItem.backBarButtonItem = back
        navigationController?.pushViewController(loginCreateAccountVC, animated: true)
    }
    
    private func animateElements() {
        Log.info("ANIMATE")

        let yTranslation = view.frame.height / 4
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
            self.headerLabel.transform = CGAffineTransform(translationX: 0, y: -yTranslation)
        }

        optionsView.fadeIn()
        UIView.animate(withDuration: 0.4) {
            self.optionsView.transform = CGAffineTransform(translationX: 0, y: -20)
        }

        shouldAnimateElements = false
//        UserDefaults.standard.set(false, forKey: "shouldAnimateElements")
    }

    private func positionHeaderLabel() {
        let yTranslation = view.frame.height / 4
        headerLabel.transform = CGAffineTransform(translationX: 0, y: -yTranslation)
    }

    @objc
    private func termsTextTapped() {
        Log.info("TERMS TAPPED")
        let termsVC = TermsDetailVC()
        let navController = UINavigationController(rootViewController: termsVC)
        present(navController, animated: true)
    }

}

extension WelcomeVC {
    enum LocalizedKeys {
        static let signInWithEmail = "welcome_sign_in_with_email"
        static let signInWithGoogle = "welcome_sign_in_with_google"
        static let createAccount = "welcome_create_account"
        static let continueWithoutAccount = "welcome_continue_without_account"
        static let terms = "welcome_terms"
        static let createAccountSubtext = "welcome_create_account_subtext"
    }
}
