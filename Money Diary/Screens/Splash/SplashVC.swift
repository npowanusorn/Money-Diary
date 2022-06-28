//
//  SplashVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-26.
//

import UIKit
import Firebase

class SplashVC: UIViewController {

    @IBOutlet private var mainLabel: TypingLabel!
    
    private var isSignedIn = false
    private var errorMessage: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLabel.setTextWithTypingAnimation("Money Diary") {
            Log.info("DONE ANIMATION")
            self.navigateToNextScreen(isSignedIn: self.isSignedIn)
        }
        
        attemptToLogIn()
    }
    
    private func attemptToLogIn() {
        if let data = UserDefaults.standard.object(forKey: "authCredential") as? Data {
            if let cred = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? AuthCredential {
                Auth.auth().signIn(with: cred) { result, error in
                    Log.info("1234")
                    if let error = error {
                        Log.error("ERROR: \(error)")
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    Log.info("IS SIGNED IN")
                    self.isSignedIn = true
                }
            }
        }
    }
    
    private func navigateToNextScreen(isSignedIn: Bool) {
        let welcomeVC = WelcomeVC()
        welcomeVC.errorMessage = errorMessage
        welcomeVC.shouldAnimateElements = true
        let dashboardVC = DashboardVC()
        if isSignedIn {
            navigationController?.setViewControllers([welcomeVC, dashboardVC], animated: true)
        } else {
            navigationController?.setViewControllers([welcomeVC], animated: false)
        }
    }

}
