//
//  TabBarViewCell.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 20/06/2022.
//

import UIKit

protocol TabBarCellDelegate {
    func didChangeToIndex(index: Int)
}

class TabBarViewCell: UITableViewCell {

    var tabBarView: TabBarView!
    var delegate: TabBarCellDelegate?

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

    private func setupCell() {
        let tabBarConfiguration: TabBarViewConfiguration = .init(frame: self.frame, buttonTitles: ["title 1", "title 2"], orientation: .top, style: .fill)
        tabBarView = TabBarView(config: tabBarConfiguration)
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tabBarView)
        tabBarView.delegate = self
        tabBarView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tabBarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        tabBarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tabBarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }

    func setTitles(titles: [String]) {
        tabBarView.setButtonTitles(buttonTitles: titles)
    }

    func setStyle(style: TabBarView.SelectionStyle) {
        tabBarView.setStyle(style: style)
    }

    func setOrientation(orientation: TabBarView.SelectionBarOrientation) {
        tabBarView.setSelectionOrientation(to: orientation)
    }

}

extension TabBarViewCell: TabBarViewDelegate {
    func didChangeToIndex(index: Int) {
        delegate?.didChangeToIndex(index: index)
    }
}
