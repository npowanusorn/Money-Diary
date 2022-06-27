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
//        navigateToNextScreen(isSignedIn: false)
        
//        _ = Auth.auth().addStateDidChangeListener({ auth, user in
//            Log.info("IS LOGGED IN: \(user != nil)")
//        })
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
        let dashboardVC = DashboardVC()
        let nextVC = isSignedIn ? dashboardVC : welcomeVC
//        navigationController?.setViewControllers([welcomeVC], animated: false)
//        if isSignedIn { navigationController?.pushViewController(dashboardVC, animated: true) }
        navigationController?.pushViewController(nextVC, animated: isSignedIn)
    }

}
