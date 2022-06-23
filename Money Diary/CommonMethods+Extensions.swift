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
//        titleLabel.font = K.Fonts.bold.getFont(size: 24)
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
//        subtitleLabel.font = K.Fonts.regular.getFont(size: 14)
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
        secondaryActionName: String?,
        secondaryActionStyle: UIAlertAction.Style,
        primaryCompletion: @escaping () -> Void,
        secondaryCompletion: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let primaryAction = UIAlertAction(title: primaryActionName, style: primaryActionStyle) { _ in primaryCompletion() }
        if let secondaryActionName = secondaryActionName {
            let secondaryAction = UIAlertAction(title: secondaryActionName, style: secondaryActionStyle) { _ in
                if let secondaryCompletion = secondaryCompletion { secondaryCompletion() }
            }
            alert.addActions([primaryAction, secondaryAction])
        } else {
            alert.addAction(primaryAction)
        }
        return alert
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

    static func showDismissAlert(with title: String, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
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
}
