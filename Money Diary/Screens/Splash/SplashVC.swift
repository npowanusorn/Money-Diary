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
    private var isAnimationDone = false
    private var isFirebaseDone = false

    private let keychain = KeychainSwift()
    private let auth = Auth.auth()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLabel.setTextWithTypingAnimation("Money Diary") {
            Log.info("DONE ANIMATION")
            self.isAnimationDone = true
            if self.isFirebaseDone { self.navigateToNextScreen(isSignedIn: self.isSignedIn) }
        }
        
        Task { await attemptToLogIn() }
    }

    private func attemptToLogIn() async {
        guard let email = keychain.get(K.KeychainKeys.emailKey), let password = keychain.get(K.KeychainKeys.passwordKey) else { return }
        let wasLoggedIn = UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.isLoggedIn)
        let error = await AuthManager.signIn(with: email, password: password)
        if error == nil || wasLoggedIn {
            self.isSignedIn = true
            await attemptToGetData()
        } else {
            Log.error("ERROR: \(error!)")
            self.errorMessage = error!.localizedDescription
        }
        isFirebaseDone = true
        if isAnimationDone { self.navigateToNextScreen(isSignedIn: self.isSignedIn)}
    }

    private func attemptToGetData() async {
        await FirestoreManager.getData()
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
