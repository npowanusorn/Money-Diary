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
        let string = String(format: "$%.2f", self)
        return string
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
    func toString(with formatterStyle: DateFormatter.Style) -> String {
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
