//
//  ConnectDesktopViewController.swift
//  Stream Kit
//
//  Created by Vinícios Barbosa on 25/10/24.
//

import UIKit

class ConnectDesktopViewController: UIViewController {

    lazy var laptopImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(named: "LaptopQrCode")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()
    
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Use o iPhone para controlar o Mac"
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Você pode conectar o seu iPhone ao Stream Kit Desktop escaneando o QR Code."
        label.textColor = .backgroundForeground
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
    
        return label
    }()

    lazy var connectDeviceButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .primary
        config.baseForegroundColor = .accent
        config.image = UIImage(systemName: "qrcode")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.cornerStyle = .large

        var titleAttributedString = AttributedString("Conectar ao Mac")
        titleAttributedString.font = .systemFont(ofSize: 16, weight: .medium)
        config.attributedTitle = titleAttributedString

        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(pushToScanQrCodeViewController), for: .touchUpInside)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setHierachy()
        setConstrains()
    }

    func setupView() {
        view.backgroundColor = .backgroundSecondary
    }

    func setHierachy() {
        view.addSubview(laptopImageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(connectDeviceButton)
    }

    func setConstrains() {
        NSLayoutConstraint.activate([
            laptopImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 72),
            laptopImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            laptopImageView.heightAnchor.constraint(equalToConstant: 100),
            laptopImageView.widthAnchor.constraint(equalToConstant: 114),
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: laptopImageView.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 0.75)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -24)])
        
        NSLayoutConstraint.activate([
            connectDeviceButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor, constant: -72),
            connectDeviceButton.heightAnchor.constraint(equalToConstant: 50),
            connectDeviceButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 24),
            connectDeviceButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    @objc func pushToScanQrCodeViewController() {
        self.navigationController?.pushViewController(ViewController(), animated: true)
    }

}
