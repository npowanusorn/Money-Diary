//
//  UIView+Fade.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-09.
//

import UIKit

extension UIView {
    func fadeIn(withDuration duration: TimeInterval = 0.4, alpha: CGFloat = 1, completion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration) {
            self.alpha = alpha
        } completion: { _ in
            completion?()
        }
    }
    
    func fadeOut(withDuration duration: TimeInterval = 0.4, alpha: CGFloat = 0, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.alpha = alpha
        } completion: { _ in
            if alpha == 0 { self.isHidden = true }
            completion?()
        }
    }
}
