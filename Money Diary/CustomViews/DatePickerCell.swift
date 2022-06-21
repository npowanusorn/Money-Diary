//
//  DatePickerCell.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import UIKit

protocol DatePickerCellDelegate {
    func didSelectDate(date: Date)
}

class DatePickerCell: UITableViewCell {

    var delegate: DatePickerCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.tintColor = globalTintColor
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(datePicker)

        datePicker.widthAnchor.constraint(equalToConstant: 350.0).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 350.0).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc
    func datePickerChanged(_ datePicker: UIDatePicker) {
        delegate?.didSelectDate(date: datePicker.date)
    }

}
