//
//  LoginCreateAccountVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 23/06/2022.
//

import UIKit
import SPIndicator

class WelcomeVC: UIViewController {
    
    var error: NSError? = nil
    var shouldAnimateElements = false

    @IBOutlet private var optionsView: UIView!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var googleButton: UIButton!
    @IBOutlet private var emailButton: BounceButton!
    @IBOutlet private var headerLabelVerticalConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let error = error {
            FIRErrorManager.handleError(error: error, viewController: self)
        }

        googleButton.setImage(UIImage(named: "Google")?.resize(newWidth: 30.0), for: .normal)
        navigationItem.setHidesBackButton(true, animated: true)
        Log.info("VIEWDIDLOAD")
        Log.info("SHOULDANIMATE: \(shouldAnimateElements)")
        if shouldAnimateElements { animateElements() }
        else { positionHeaderLabel() }

        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers
        navigationArray.removeFirst()
        self.navigationController?.viewControllers = navigationArray
    }

    @IBAction func signInWithGoogleTapped(_ sender: Any) {
        Log.info("SIGN IN WITH GOOGLE")
        SPIndicator.present(title: "Success", message: "Logged in", preset: .done, haptic: .success) {
//            self.goToNext()
        }
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

}
