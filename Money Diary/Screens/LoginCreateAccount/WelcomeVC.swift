//
//  LoginCreateAccountVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 23/06/2022.
//

import UIKit
import SPIndicator

class WelcomeVC: UIViewController {

    @IBOutlet var headerLabel: TypingLabel!
    @IBOutlet var googleButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.text = "Money Diary"
        googleButton.setImage(UIImage(named: "Google")?.resize(newWidth: 30.0), for: .normal)
    }

    @IBAction func signInWithGoogleTapped(_ sender: Any) {
        Log.info("sign in with google")
        SPIndicator.present(title: "Success", message: "Logged in", preset: .done, haptic: .success) {
//            self.goToNext()
        }
    }

    @IBAction func signInWithEmailTapped(_ sender: Any) {
        Log.info("sign in with email")
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
        navigationItem.backBarButtonItem = back
        navigationController?.pushViewController(loginCreateAccountVC, animated: true)
    }

}
