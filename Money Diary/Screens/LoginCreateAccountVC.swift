//
//  LoginCreateAccountVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 23/06/2022.
//

import UIKit

class LoginCreateAccountVC: UIViewController {

    @IBOutlet var headerLabel: TypingLabel!
    @IBOutlet var googleButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.text = "Money Diary"
    }

    @IBAction func signInWithGoogleTapped(_ sender: Any) {
        goToDashboard()
    }

    @IBAction func signInWithEmailTapped(_ sender: Any) {
        goToDashboard()
    }

    @IBAction func createAccountTapped(_ sender: Any) {
        goToDashboard()
    }

    private func goToDashboard() {
        let dashboardVC = DashboardVC()
        navigationController?.pushViewController(dashboardVC, animated: true)
    }

}
