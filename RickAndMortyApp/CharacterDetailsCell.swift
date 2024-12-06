//
//  DetailsCell.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 09.08.2024.
//

import UIKit

class CharacterDetailCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .systemGray
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel.font = UIFont.systemFont(ofSize: 18)
        valueLabel.textColor = .black
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            // titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // valueLabel constraints
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
