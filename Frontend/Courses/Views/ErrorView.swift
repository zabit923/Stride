//
//  ErrorView.swift
//  Courses
//
//  Created by Руслан on 22.08.2024.
//

import Foundation
import UIKit

class ErrorView: UIView {

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 3
            return stackView
        }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SFProRounded-Semibold", size: 14)!
        label.textColor = .white
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont(name: "SFProRounded-Regular", size: 10)!
        label.textColor = .white
        return label
    }()

    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func designView() {
        self.backgroundColor = UIColor.errorRed
        self.layer.cornerRadius = 10
    }

    // Setup UI
    private func setupView() {
        // Add subviews
        addSubview(imageView)
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        designView()

        // Set constraints
        NSLayoutConstraint.activate([
            // Image View Constraints
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 25),
            imageView.heightAnchor.constraint(equalToConstant: 25),

            contentStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            centerYAnchor.constraint(equalTo: contentStackView.centerYAnchor, constant: 0),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 15),
        ])
    }

    // Setters for data
    func configure(image: UIImage = UIImage.error, title: String, description: String) {
        imageView.image = image
        titleLabel.text = title
        descriptionLabel.text = description
    }

    func swipe(sender: UIPanGestureRecognizer, startPosition: CGPoint) {
        let translation = sender.translation(in: self)
        switch sender.state {
        case .changed:
            self.center = CGPoint(x: self.center.x, y: self.center.y +  translation.y)
            sender.setTranslation(CGPoint.zero, in: self)
        case .ended:
            if self.center.y <= 40 {
                self.self.isHidden = true
            }
            UIView.animate(withDuration: 0.5) {
                self.center = startPosition
            }
        default:
            break
        }
    }

}
