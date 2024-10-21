//
//  PadsCollectionCellView.swift
//  Stream Kit
//
//  Created by Vinícios Barbosa on 21/10/24.
//

import UIKit

class PadsCollectionCellView: UICollectionViewCell {
    static let identifier: String = "PadsCollectionViewCell"
    
    private var padId: Int?
    private var onTap: ((_ id: Int) -> Void)?
    
    private let padImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    lazy var padButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.backgroundColor = .backgroundPrimary
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func setupView() {
        setHierarchy()
        setConstrains()
    }
    
    private func setHierarchy() {
        contentView.addSubview(padButton)
        padButton.addSubview(padImageView)
    }
    
    private func setConstrains() {
        NSLayoutConstraint.activate([
            padButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            padButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            padButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            padButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            padImageView.topAnchor.constraint(equalTo: padButton.topAnchor),
            padImageView.leadingAnchor.constraint(equalTo: padButton.leadingAnchor),
            padImageView.trailingAnchor.constraint(equalTo: padButton.trailingAnchor),
            padImageView.bottomAnchor.constraint(equalTo: padButton.bottomAnchor)
        ])
    }

    func configure(with pad: Pad, onTap: @escaping (_ id: Int) -> Void) {
        self.padId = pad.id
        self.onTap = onTap
        loadImage(from: pad.image)
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            padImageView.image = nil
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.padImageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self?.padImageView.image = nil
                }
            }
        }
        
        task.resume()
    }
    
    @objc private func buttonTapped() {
        guard let id = padId else { return }
        onTap?(id)
    }
}
