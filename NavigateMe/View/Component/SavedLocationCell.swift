//
//  SavedLocationCell.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 28.1.23..
//

import UIKit

protocol OpenGoogleMapsDelegate {
    func openGoogleMaps(cell: SavedLocationCell)
}

class SavedLocationCell: UITableViewCell {
    
    let countryFlag: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private lazy var googleMapsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "googleMaps"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openGoogleMaps), for: .touchUpInside)
        return button
    }()
    
    static let indentifier = "SavedLocationCell"
    
    var delegate: OpenGoogleMapsDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUIElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openGoogleMaps() {
        delegate?.openGoogleMaps(cell: self)
    }
}

// MARK: - UI Elements
extension SavedLocationCell {
    // MARK: - Set UI Elements
    private func setUIElements() {
        contentView.addSubview(countryFlag)
        contentView.addSubview(nameLabel)
        contentView.addSubview(googleMapsButton)
        
        setConstains()
    }
    
    // MARK: - Set Cell Constrains
    private func setConstains() {
        countryFlag.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        countryFlag.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        countryFlag.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: countryFlag.rightAnchor, constant: 16).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: googleMapsButton.leftAnchor, constant: -16).isActive = true
        
        googleMapsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        googleMapsButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        googleMapsButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        googleMapsButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
}
