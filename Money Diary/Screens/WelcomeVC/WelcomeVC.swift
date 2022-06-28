//
//  LoginCreateAccountVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 23/06/2022.
//

import UIKit
import SPIndicator

class WelcomeVC: UIViewController {
    
    var errorMessage: String? = nil
    var shouldAnimateElements = false

    @IBOutlet private var optionsView: UIView!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var googleButton: UIButton!
    @IBOutlet private var emailButton: BounceButton!
    @IBOutlet private var headerLabelVerticalConstraint: NSLayoutConstraint!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        shouldAnimateElements = UserDefaults.standard.bool(forKey: "shouldAnimateElements")
//        if shouldAnimateElements ?? false { animateElements() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let errorMessage = errorMessage {
            let alert = UIAlertController.showErrorAlert(title: "Log in failed", message: errorMessage)
            present(alert, animated: true)
        }

        googleButton.setImage(UIImage(named: "Google")?.resize(newWidth: 30.0), for: .normal)
        navigationItem.setHidesBackButton(true, animated: true)
        Log.info("VIEWDIDLOAD")
        Log.info("SHOULDANIMATE: \(shouldAnimateElements)")
        if shouldAnimateElements { animateElements() }
        else { positionHeaderLabel() }
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
