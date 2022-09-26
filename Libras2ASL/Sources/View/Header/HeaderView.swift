//
//  HeaderView.swift
//  Libras2ASL
//
//  Created by Gustavo Rigor on 07/09/22.
//

import UIKit

class HeaderView: UIView {
    
    var descriptionLabel: UILabel
    var wordLabel: UILabel
    
    var viewModel: HeaderViewModel? {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        descriptionLabel = UILabel()
        wordLabel = UILabel()
        super.init(frame: frame)
        self.backgroundColor = .green
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        if let vm = viewModel {
            descriptionLabel.text = vm.descriptionText
            wordLabel.text = vm.wordText
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func setupViews() {

        descriptionLabel.textAlignment = .center
        descriptionLabel.backgroundColor =  .darkGray
        descriptionLabel.textColor =  .black
        descriptionLabel.layer.cornerRadius = 10
        descriptionLabel.layer.masksToBounds = true
        
        wordLabel.textAlignment = .center
        wordLabel.textColor =  .white
        wordLabel.backgroundColor = .none
        wordLabel.layer.masksToBounds = true
        
        addSubview(descriptionLabel)
        addSubview(wordLabel)
        setupConstraints()
    }
    
    func setupConstraints() {
        descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        descriptionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        wordLabel.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 10).isActive = true
        wordLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        wordLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        wordLabel.trailingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        wordLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}
