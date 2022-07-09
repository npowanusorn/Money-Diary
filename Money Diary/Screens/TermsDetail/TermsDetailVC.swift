//
//  TermsDetailVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-07-08.
//

import UIKit

class TermsDetailVC: UIViewController {

    @IBOutlet private var termsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedKeys.title.localized
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: ImageName.cross), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc
    private func dismissVC() {
        dismiss(animated: true)
    }

}

extension TermsDetailVC {
    enum LocalizedKeys {
        static let title = "terms_title"
    }
    enum ImageName {
        static let cross = "xmark"
    }
}
