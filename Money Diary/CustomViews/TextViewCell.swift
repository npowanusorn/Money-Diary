//
//  TextViewCell.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import UIKit

protocol TextViewCellDelegate {
    func textViewDidChange(text: String, tag: Int)
}

class TextViewCell: UITableViewCell {

    var delegate: TextViewCellDelegate?
    private var label: UILabel?
    var textView: UITextView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupCell() {
        let textView = UITextView()
        self.textView = textView
        let placeholderLabel = UILabel()
        label = placeholderLabel
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Avenir Next Regular", size: 17)
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "Note"
        placeholderLabel.font = UIFont(name: "Avenir Next Regular", size: 17)
        placeholderLabel.textColor = .placeholderText
        textView.delegate = self
        contentView.addSubview(textView)
        contentView.addSubview(placeholderLabel)

        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 15).isActive = true
        textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true

        placeholderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        placeholderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
    }

    func setPlaceholder(with placeholder: String) {
        label?.text = placeholder
    }

}

extension TextViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        label?.isHidden = textView.hasText
        delegate?.textViewDidChange(text: textView.text ?? "", tag: textView.tag)
    }
}
