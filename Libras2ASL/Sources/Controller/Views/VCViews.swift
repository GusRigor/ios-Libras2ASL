//
//  VCViews.swift
//  Libras2ASL
//
//  Created by Gustavo Rigor on 03/10/22.
//

import UIKit

extension ViewController {
    
    func setupView() {
        title = "Libras2ASL"
        
        let gifHiURL : String = "https://pa1.narvii.com/6427/90f2abb40e1757de174ffffe9bc5afb8e6845c60_hq.gif"
        let gifEatURL : String = "https://www.lifeprint.com/asl101/gifs/e/eat.gif"
        
        if let image = UIImage.gifImageWithURL(gifEatURL) {
            imageEat = image
        }
        
        if let image = UIImage.gifImageWithURL(gifHiURL) {
            imageHi = image
        }
        
        addDescriptionView()
        addImageView()
        addResetButton()
    }
    
    func addImageView() {
//        let gifURL : String = "https://www.lifeprint.com/asl101/gifs/e/eat.gif"
//        let gif = UIImage.gifImageWithURL(gifURL)
//
//        gifImage.image = gif
        gifImage.backgroundColor =  .white
        gifImage.layer.cornerRadius = 10
        gifImage.layer.masksToBounds = true
        
        gifImage.frame = CGRect(x: 100.0, y: 120.0, width: 200, height: 200.0)
        
        view.addSubview(gifImage)
        
        addImageViewConstraints()
    }
    
    func addImageViewConstraints() {
        gifImage.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 10).isActive = true
        gifImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        gifImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
    }
    
    func addDescriptionView() {
        descriptionLabel.text = "Faça uma palavra em Libras:"
        descriptionLabel.textAlignment = .center
        descriptionLabel.backgroundColor =  .white
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 20.0)
        descriptionLabel.layer.cornerRadius = 10
        descriptionLabel.layer.masksToBounds = true
        
        view.addSubview(descriptionLabel)
        
        addDescriptionViewConstraints()
    }
    
    func addDescriptionViewConstraints() {
        descriptionLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func addCameraView() {
        
        view.addSubview(cameraView)
        
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cameraView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 350).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 350).isActive = true
    }
    
    func addResetButton() {
        resetButton.backgroundColor =  .white
        resetButton.tintColor = .black
        
        resetButton.setTitle("Resetar palavra", for: .normal)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        
        view.addSubview(resetButton)
        
        resetButton.frame = CGRect(x: 120.0, y: 330.0, width: 150, height: 50.0)
    }
}
