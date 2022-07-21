//
//  SplashVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-26.
//

import UIKit
import Firebase
import KeychainSwift
import RealmSwift
import UIOnboarding

class SplashVC: UIViewController {

    @IBOutlet private var mainLabel: TypingLabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var isSignedIn = false
    private var error: NSError? = nil
    private var isAnimationDone = false
    private var isFirebaseDone = false
    private var completion: (()->Void)?

    private let keychain = KeychainSwift()
    private let auth = Auth.auth()
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true

        mainLabel.setTextWithTypingAnimation("Money Diary") {
            Log.info("DONE ANIMATION")
            self.isAnimationDone = true
            if self.isFirebaseDone {
                self.navigateToNextScreen(isSignedIn: self.isSignedIn)
                return
            }
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        if isLocalAccount {
            loadLocalData()
            isSignedIn = true
            isFirebaseDone = true
            return
        }

        Task { await attemptToLogIn() }
    }

    private func attemptToLogIn() async {
        let wasLoggedIn = UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.isLoggedIn)
        Log.info("WAS LOGGED IN: \(wasLoggedIn)")
        Log.info("IS INTERNET AVAILABLE: \(NetworkManager.shared.isInternetAvailable)")
        if !NetworkManager.shared.isInternetAvailable {
            self.isSignedIn = wasLoggedIn
            if isSignedIn { await attemptToGetData() }
        } else {
            guard let email = keychain.get(K.KeychainKeys.emailKey), let password = keychain.get(K.KeychainKeys.passwordKey) else {
                Log.info("NO EMAIL/PASSWORD IN KEYCHAIN")
                self.isFirebaseDone = true
                if self.isAnimationDone { self.navigateToNextScreen(isSignedIn: self.isSignedIn) }
                return
            }
            let error = await AuthManager.signIn(with: email, password: password)
            if let error = error {
                Log.error("ERROR SIGNING IN: \(error)")
                self.error = error as NSError?
                clearAllData()
            } else {
                self.isSignedIn = true
                await attemptToGetData()
            }
        }
        isFirebaseDone = true
        if isAnimationDone { self.navigateToNextScreen(isSignedIn: self.isSignedIn)}
    }

    private func attemptToGetData() async {
        await FirestoreManager.getData()
    }

    private func beginBiometrics() async {
        guard BiometryManager.shared.checkBiometrics() == nil else { return }
        guard await BiometryManager.shared.logInWithBiometrics() == nil else { return }
    }

    private func navigateToNextScreen(isSignedIn: Bool) {
        let welcomeVC = WelcomeVC()
        welcomeVC.error = error as NSError?
        if isSignedIn {
            Log.info("GO TO DASHBOARD")
            showDashboard(isFromSplash: true)
        } else {
            Log.info("GO TO WELCOME")
            welcomeVC.shouldAnimateElements = true
            
            completion = { self.navigationController?.viewControllers = [welcomeVC] }
            
            if !UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.hasCompletedOnboard) {
                let onboardingVC = UIOnboardingViewController(withConfiguration: .setup())
                onboardingVC.delegate = self
                navigationController?.present(onboardingVC, animated: true)
            } else {
                completion?()
            }
        }
    }
    
    private func loadLocalData() {
        Log.info("**** LOAD LOCAL REALM DATA ****")
        
        do {
            let realm = try Realm()
            let allWallets = realm.objects(Wallet.self)
            let allRecords = realm.objects(Record.self)

            allWallets.forEach { wallet in
                WalletManager.shared.addWallet(newWallet: wallet)
            }

            allRecords.forEach { record in
                RecordManager.shared.addRecord(newRecord: record)
            }
        } catch {
            Log.error("ERROR READING REALM DATA: \(error)")
        }
    }

}

extension SplashVC: UIOnboardingViewControllerDelegate {
    func didFinishOnboarding(onboardingViewController: UIOnboardingViewController) {
        onboardingViewController.dismiss(animated: true) {
            UserDefaults.standard.set(true, forKey: K.UserDefaultsKeys.hasCompletedOnboard)
            self.completion?()
        }
    }
}
