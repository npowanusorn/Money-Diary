//
//  CommonExtensions.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 20/06/2022.
//

import UIKit
import CoreImage
import KeychainSwift
import UIOnboarding

private var tintColor: UIColor = .tintColor

var isLocalAccount: Bool {
    UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.localAccount)
}

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

func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: closure
    )
}

func main(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func background(closure: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async {
        closure()
    }
}

func clearAllData() {
    let keychain = KeychainSwift()
    keychain.clear()
    WalletManager.shared.removeAllWallets()
    RecordManager.shared.removeAllRecords()
}

func generateUID() -> String {
    UUID().uuidString
}

func makeDate(day: Int, month: Int, year: Int) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    let components = DateComponents(year: year, month: month, day: day)
    return calendar.date(from: components) ?? .distantPast
}

// MARK: - String
extension String {
    func toCurrencyFormat() -> String {
        let formattedString = String(format: "$%.2f", self)
        return "\(formattedString)"
    }

    var localized: String { NSLocalizedString(self, comment: "") }

    func localizeWithFormat(arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }

    func localizeByPropagating(string: String) -> String {
        self.localized.replacingOccurrences(of: "%@", with: string)
    }

    var isValidDouble: Bool {
        return Double(self) != nil
    }

    var isValidInteger: Bool {
        return Int(self) != nil
    }
}

// MARK: - Double
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

// MARK: - UINavigationItem
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

// MARK: - Date
extension Date {
    func toString(withFormat formatterStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = formatterStyle
        if formatterStyle == .full || formatterStyle == .long {
            return dateFormatter.string(from: self)
        }
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else if Calendar.current.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            return dateFormatter.string(from: self)
        }
    }
}

// MARK: - Collection
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UIImage
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

// MARK: - UIWindow
extension UIWindow {
    func reload() {
        subviews.forEach { view in
            view.removeFromSuperview()
            addSubview(view)
        }
    }
}

// MARK: - UIAlertController
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

// MARK: - UIButton
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

// MARK: - StringProtocol
extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

// MARK: - UILabel
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
                Task {
                    try await Task.sleep(seconds: 0.5)
                    completion?()
                }
            }
        }
    }
}

// MARK: - UIView
extension UIView {
    func animateClickStart(withDuration duration: TimeInterval = 0.1, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            completion?()
        }
    }
    
    func restoreAnimation(withDuration duration: TimeInterval = 0.1, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform.identity
        } completion: { _ in
            completion?()
        }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func animateClick(withDuration duration: TimeInterval = 0.1, completion: (() -> Void)? = nil) {
        animateClickStart(withDuration: duration) {
            self.restoreAnimation(withDuration: duration) {
                completion?()
            }
        }
    }
}

// MARK: - NSLayoutConstraint
extension NSLayoutConstraint {
    /**
     Change multiplier constraint

     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
    */
    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

// MARK: - Task
extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

// MARK: - UIStackView
extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
}

// MARK: - UIViewController
extension UIViewController {
    func showDashboard(isFromSplash: Bool) {
        let tabController = TabBarController()
        navigationController?.pushViewController(tabController, animated: true, completion: {
            if isFromSplash {
                self.navigationController?.viewControllers = [WelcomeVC(), tabController]
            }
        })
    }
}

// MARK: - UINavigationController
extension UINavigationController {
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}

// MARK: - UIOnboardingViewConfiguration
extension UIOnboardingViewConfiguration {
    private struct OnboardConfigurationHelper {
        static func getIcon() -> UIImage {
            Bundle.main.appIcon ?? UIImage()
        }
        
        static func firstLineTitle() -> NSMutableAttributedString {
            .init(string: "Welcome to", attributes: [.foregroundColor: UIColor.label])
        }
        
        static func secondLineTitle() -> NSMutableAttributedString {
            .init(string: Bundle.main.displayName ?? "Money Diary", attributes: [.foregroundColor: globalTintColor])
        }
        
        static func features() -> Array<UIOnboardingFeature> {
            .init([
                .init(
                    icon: UIImage(systemName: "swift") ?? UIImage(),
                    iconTint: globalTintColor,
                    title: "Feature 1",
                    description: "Description 1"
                ),
                .init(
                    icon: UIImage(systemName: "paperplane.fill") ?? UIImage(),
                    iconTint: globalTintColor,
                    title: "Feature 2",
                    description: "Description 2"
                )
            ])
        }
        
        static func textView() -> UIOnboardingTextViewConfiguration {
            .init(icon: UIImage(), text: "")
        }
        
        static func setupButton() -> UIOnboardingButtonConfiguration {
            .init(title: "Continue", backgroundColor: globalTintColor)
        }
    }
    
    static func setup() -> UIOnboardingViewConfiguration {
        .init(
            appIcon: OnboardConfigurationHelper.getIcon(),
            firstTitleLine: OnboardConfigurationHelper.firstLineTitle(),
            secondTitleLine: OnboardConfigurationHelper.secondLineTitle(),
            features: OnboardConfigurationHelper.features(),
            textViewConfiguration: OnboardConfigurationHelper.textView(),
            buttonConfiguration: OnboardConfigurationHelper.setupButton()
        )
    }
}

// MARK: - NotificationCenter
extension NotificationCenter {
    func post(name: String, object: Any?) {
        let notificationName = Notification.Name(name)
        post(name: notificationName, object: object)
    }

    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: String, object anObject: Any?) {
        let notificationName = Notification.Name(aName)
        addObserver(observer, selector: aSelector, name: notificationName, object: anObject)
    }

    func removeObserver(_ observer: Any, name aName: String, object anObject: Any?) {
        let notificationName = Notification.Name(aName)
        removeObserver(observer, name: notificationName, object: anObject)
    }
    
}

// MARK: - UITableViewCell
extension UITableViewCell {
    func getText() -> String? {
        guard let content = contentConfiguration as? UIListContentConfiguration else { return nil }
        return content.text
    }
}
