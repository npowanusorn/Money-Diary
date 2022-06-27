//
//  CommonExtensions.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 20/06/2022.
//

import UIKit
import CoreImage

private var tintColor: UIColor = .tintColor
var globalTintColor: UIColor {
    get { return tintColor }
    set { tintColor = newValue }
}

func performHaptics() {
    UISelectionFeedbackGenerator().selectionChanged()
}

func getAttributedStringDict(fontSize: CGFloat, weight: UIFont.Weight) -> [NSAttributedString.Key : Any] {
    return [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize, weight: weight)]
}

func getAttributedString(for title: String, fontSize: CGFloat, weight: UIFont.Weight) -> NSAttributedString {
    return NSAttributedString(string: title, attributes: getAttributedStringDict(fontSize: fontSize, weight: weight))
}

func getAttributedString(for title: String, fontSize: CGFloat, weight: UIFont.Weight) -> AttributedString {
    return AttributedString(getAttributedString(for: title, fontSize: fontSize, weight: weight))
}

extension String {
    func toCurrencyFormat() -> String {
        let formattedString = String(format: "$%.2f", self)
        return "\(formattedString)"
    }
}

extension Double {
    func toCurrencyString() -> String {
        if self < 0 {
            return String(format: "-$%.2f", abs(self))
        } else {
            return String(format: "$%.2f", self)
        }
    }

    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UINavigationItem {
    func setTitleAndSubtitle(title: String, subtitle: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()

        let stack = UIStackView(arrangedSubviews: [subtitleLabel, titleLabel])
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.alignment = .leading

        let width = max(titleLabel.frame.size.width, subtitleLabel.frame.size.width)
        stack.frame = CGRect(x: 0, y: 0, width: width, height: 50)

        titleLabel.sizeToFit()
        subtitleLabel.sizeToFit()

        self.titleView = stack
    }
}

extension Date {
    func toString(withFormat formatterStyle: DateFormatter.Style) -> String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else if Calendar.current.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = formatterStyle
            return dateFormatter.string(from: self)
        }
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIImage {
    func resize(newWidth desiredWidth: CGFloat) -> UIImage {
        let oldWidth = size.width
        let scaleFactor = desiredWidth / oldWidth
        let newHeight = size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        return resize(targetSize: newSize)
    }

    func resize(newHeight desiredHeight: CGFloat) -> UIImage {
        let scaleFactor = desiredHeight / size.height
        let newWidth = size.width * scaleFactor
        let newSize = CGSize(width: newWidth, height: desiredHeight)
        return resize(targetSize: newSize)
    }

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        self.init(cgImage: aCgImage)
    }
}

extension UIWindow {
    func reload() {
        subviews.forEach { view in
            view.removeFromSuperview()
            addSubview(view)
        }
    }
}

extension UIAlertController {
    func addActions(_ actions: [UIAlertAction]) {
        for action in actions {
            addAction(action)
        }
    }

    static func showAlert(
        with title: String?,
        message: String?,
        style: UIAlertController.Style,
        primaryActionName: String,
        primaryActionStyle: UIAlertAction.Style,
        secondaryActionName: String? = nil,
        secondaryActionStyle: UIAlertAction.Style? = nil,
        primaryCompletion: (() -> Void)?,
        secondaryCompletion: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let primaryAction = UIAlertAction(title: primaryActionName, style: primaryActionStyle) { _ in primaryCompletion?() }
        if let secondaryActionName = secondaryActionName, let secondaryActionStyle = secondaryActionStyle {
            let secondaryAction = UIAlertAction(title: secondaryActionName, style: secondaryActionStyle) { _ in
                secondaryCompletion?()
            }
            alert.addActions([primaryAction, secondaryAction])
        } else {
            alert.addAction(primaryAction)
        }
        return alert
    }
    
    static func showErrorAlert(title: String = "Error", message: String, completion: (() -> Void)? = nil) -> UIAlertController {
        return showDismissAlert(with: title, message: message, completion: completion)
    }

    static func showDeleteConfirmationAlert(
        with title: String,
        message: String?,
        primaryCompletion: @escaping () -> Void,
        secondaryCompletion: (() -> Void)? = nil
    ) -> UIAlertController {
        return showAlert(
            with: title,
            message: message,
            style: .alert,
            primaryActionName: "Delete",
            primaryActionStyle: .destructive,
            secondaryActionName: "Cancel",
            secondaryActionStyle: .cancel,
            primaryCompletion: primaryCompletion,
            secondaryCompletion: secondaryCompletion
        )
    }
    
    static func showOkAlert(with title: String, message: String?, completion: (() -> Void)? = nil) -> UIAlertController {
        UIAlertController.showAlert(with: title, message: message, style: .alert, primaryActionName: "Ok", primaryActionStyle: .cancel, primaryCompletion: completion)
    }

    static func showDismissAlert(with title: String, message: String?, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            completion?()
        }
        alert.addAction(dismissAction)
        return alert
    }

    static func showDismissScreenAlertSheet(
        title: String?,
        message: String?,
        actionTitle: String,
        completion: @escaping () -> Void
    ) -> UIAlertController {
        return showAlert(
            with: title,
            message: message,
            style: .actionSheet,
            primaryActionName: actionTitle,
            primaryActionStyle: .destructive,
            secondaryActionName: "Cancel",
            secondaryActionStyle: .cancel,
            primaryCompletion: completion
        )
    }

    static func showUnsavedChangesSheet(completion: @escaping () -> Void) -> UIAlertController {
        return showDismissScreenAlertSheet(
            title: "You have unsaved changes",
            message: nil,
            actionTitle: "Discard Changes",
            completion: completion
        )
    }
    
    static func showTextFieldAlert(with title: String, message: String?, actionTitle: String, completion: @escaping (_ textField: UITextField) -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField()
        
        let submitAction = UIAlertAction(title: actionTitle, style: .destructive) { _ in
            guard let textField = alertController.textFields?[0] else { return }
            completion(textField)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addActions([submitAction, cancelAction])
        return alertController
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

extension UILabel {
    func setTextWithTypingAnimation(_ text: String, delay: TimeInterval = 0.1, completion: (() -> Void)?) {
        let textLength = text.count
        var counter = 0
        self.text = ""
        Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { timer in
            if counter < textLength {
                self.text! += String(text[counter])
                counter += 1
            } else {
                timer.invalidate()
                sleep(1)
                completion?()
            }
        }
    }
}

extension UIView {
    func restoreAnimation(withDuration duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform.identity
        } completion: { _ in
            completion?()
        }
    }
}
