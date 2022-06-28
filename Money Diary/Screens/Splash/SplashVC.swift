//
//  SplashVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-26.
//

import UIKit
import Firebase
import KeychainSwift

class SplashVC: UIViewController {

    @IBOutlet private var mainLabel: TypingLabel!
    
    private var isSignedIn = false
    private var errorMessage: String? = nil

    private let keychain = KeychainSwift()
    private let auth = Auth.auth()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLabel.setTextWithTypingAnimation("Money Diary") {
            Log.info("DONE ANIMATION")
            self.navigateToNextScreen(isSignedIn: self.isSignedIn)
        }
        
        attemptToLogIn()
    }
    
    private func attemptToLogIn() {
        guard let email = keychain.get(K.KeychainKeys.emailKey), let password = keychain.get(K.KeychainKeys.passwordKey) else { return }
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }
            if let error = error {
                Log.error("ERROR: \(error)")
                strongSelf.errorMessage = error.localizedDescription
                return
            }
            Log.info("IS SIGNED IN")
            strongSelf.isSignedIn = true
        }
    }
    
    private func navigateToNextScreen(isSignedIn: Bool) {
        let welcomeVC = WelcomeVC()
        welcomeVC.errorMessage = errorMessage
        let dashboardVC = DashboardVC()
        if isSignedIn {
            Log.info("GO TO DASHBOARD")
            navigationController?.setViewControllers([welcomeVC, dashboardVC], animated: true)
        } else {
            Log.info("GO TO WELCOME")
            welcomeVC.shouldAnimateElements = true
            navigationController?.setViewControllers([welcomeVC], animated: false)
        }
    }

}
