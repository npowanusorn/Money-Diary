//
//  UIView+Fade.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-09.
//

import UIKit

extension UIView {
    func fadeIn(withDuration duration: TimeInterval?, alpha: CGFloat? = 1, completion: (() -> Void)? = nil) {
        self.alpha = 0
        UIView.animate(withDuration: duration ?? 0.4) {
            self.alpha = alpha ?? 1
        } completion: { _ in
            completion?()
        }
    }
    
    func fadeOut(withDuration duration: TimeInterval?, alpha: CGFloat? = 0, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration ?? 0.4) {
            self.alpha = alpha ?? 0
        } completion: { _ in
            completion?()
        }
    }
}
