//
//  EpisodeCell.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 27.07.2024.
//

import UIKit

class EpisodeCell: UICollectionViewCell {

    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let episodeLabel = UILabel()
    private let imageView = UIImageView()
    private let grayColorView = UIView()
    private let likeButton = UIButton()
    private let watchButton = UIButton()
    private var cachedImage: UIImage?
    private var cachedCharacter: Character?


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(grayColorView)
        containerView.addSubview(watchButton)
        containerView.addSubview(nameLabel)
        containerView.addSubview(episodeLabel)
        containerView.addSubview(likeButton)
        
        // Настройка containerView
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = false
        containerView.frame = contentView.bounds.insetBy(dx: 10, dy: 10)
        containerView.clipsToBounds = true
        
        // Настройка imageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: 200)
        imageView.layer.cornerRadius = 8

        // Настройка grayColorView
        grayColorView.frame = CGRect(x: 0, y: imageView.frame.maxY + 35, width: containerView.frame.width, height: containerView.frame.height - imageView.frame.height - 35)
        grayColorView.backgroundColor = .systemGray6
        grayColorView.layer.cornerRadius = 8
        applyCornerRadius(to: grayColorView, corners: [.topLeft, .topRight], radius: 20)
        
        // Настройка nameLabel
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.numberOfLines = 1
        nameLabel.frame = CGRect(x: 20, y: imageView.frame.maxY + 10, width: containerView.frame.width - 64, height: 20)
        
        // Настройка кнопки Watch
        watchButton.setImage(UIImage(named: "play.tv"), for: .normal)
        watchButton.setTitle("Pilot |", for: .normal)
        watchButton.setTitleColor(.black, for: .normal)
        watchButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        watchButton.frame = CGRect(x: 8, y: nameLabel.frame.maxY + 10, width: 100, height: 48)
        watchButton.tintColor = .black
        watchButton.layer.masksToBounds = true

        // Настройка episodeLabel
        episodeLabel.font = UIFont.systemFont(ofSize: 14)
        episodeLabel.numberOfLines = 1
        episodeLabel.textColor = .black
        episodeLabel.frame = CGRect(x: nameLabel.frame.minX + 90, y: watchButton.frame.maxY - 33, width: containerView.frame.width - 16, height: 20)

        // Настройка кнопки лайк
        likeButton.setImage(UIImage(named: "clearHeart"), for: .normal)
        likeButton.frame = CGRect(x: containerView.frame.width - 32 - 20, y: watchButton.frame.maxY - 35, width: 36, height: 30)
        likeButton.tintColor = .systemBlue
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)

        configureShadow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with episode: Episode, imageURL: String?) {
        nameLabel.text = episode.name
        episodeLabel.text = episode.episode
        
        if let cachedImage = cachedImage {
            imageView.image = cachedImage
        } else if let imageURLString = imageURL, let url = URL(string: imageURLString) {
            imageView.loadImage(from: url) { [weak self] image in
                self?.cachedImage = image
                self?.imageView.image = image
            }
        } else {
            imageView.image = nil
        }
    }

    
    @objc private func likeButtonTapped() {
        likeButton.isSelected.toggle()
        let heartImage = likeButton.isSelected ? UIImage(named: "redHeart") : UIImage(named: "clearHeart")
        let tintColor = likeButton.isSelected ? UIColor.red : UIColor.clear

        UIView.transition(with: likeButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.likeButton.setImage(heartImage, for: .normal)
            self.likeButton.tintColor = tintColor
        }, completion: nil)

        UIView.animate(withDuration: 0.1,
                       animations: {
                        self.likeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.1) {
                               self.likeButton.transform = CGAffineTransform.identity
                           }
                       })

       // Настройка избранных - "лайк"
        if likeButton.isSelected {
            addEpisodeToFavourites()
        } else {
            removeEpisodeFromFavourites()
        }
    }

    private func addEpisodeToFavourites() {
        // Your logic to add episode to favourites
    }

    private func removeEpisodeFromFavourites() {
        // Your logic to remove episode from favourites
    }

    // Настройка теней
    func configureShadow() {
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = false
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 2

        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    // Скругления углов
    private func applyCornerRadius(to view: UIView, corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }
}

extension UIImageView {
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

