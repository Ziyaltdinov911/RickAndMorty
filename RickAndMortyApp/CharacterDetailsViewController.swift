//
//  CharacterDetailsViewController.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 27.07.2024.
//

import UIKit
import Combine

class CharacterDetailsViewController: UIViewController, UITableViewDataSource {
    
    var episode: Episode?
    
    private let imageView = UIImageView()
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "cameraIcon"), for: .normal)
        button.frame.size.height = 32
        button.frame.size.width = 32
        button.tintColor = .black
        return button
    }()
    private let characterNameLabel = UILabel()
    private let informationsTextLabel = UILabel()
    private let tableView = UITableView()
    
    private var characterDetails: [(title: String, value: String?)] = []
    private var cancellables = Set<AnyCancellable>()
    private var photoChangeHandler: PhotoChangeHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupNavigationBar()
        loadCharacterDetails()
        
        photoChangeHandler = PhotoChangeHandler(viewController: self, imageView: imageView)
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        // Создание кнопки "Go Back" с текстом и стрелкой
        let backButton = UIButton(type: .system)
        backButton.setTitle("GO BACK", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .black
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let searchImageView = UIImageView(image: UIImage(named: "logo-black 1"))
        searchImageView.contentMode = .scaleAspectFit
        searchImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let searchBarButtonItem = UIBarButtonItem(customView: searchImageView)
        
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.rightBarButtonItem = searchBarButtonItem
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
        
    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(changePhotoButton)
        view.addSubview(characterNameLabel)
        view.addSubview(informationsTextLabel)
        view.addSubview(tableView)
        
        // Настройка imageView
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: (view.frame.width - 148) / 2, y: view.safeAreaInsets.top + 124, width: 148, height: 148)
        imageView.layer.cornerRadius = 74
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1).cgColor
        imageView.clipsToBounds = true
        
        // Настройка changePhotoButton
        changePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changePhotoButton.widthAnchor.constraint(equalToConstant: 32),
            changePhotoButton.heightAnchor.constraint(equalToConstant: 32),
            changePhotoButton.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            changePhotoButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        // Настройка characterNameLabel
        characterNameLabel.textAlignment = .center
        characterNameLabel.font = UIFont.systemFont(ofSize: 32)
        characterNameLabel.frame = CGRect(x: 16, y: imageView.frame.maxY + 20, width: view.frame.width - 32, height: 32)
        
        // Настройка informationsTextLabel
        informationsTextLabel.text = "Informations"
        informationsTextLabel.font = UIFont.boldSystemFont(ofSize: 24)
        informationsTextLabel.textAlignment = .left
        informationsTextLabel.textColor = .systemGray
        informationsTextLabel.frame = CGRect(x: 20, y: characterNameLabel.frame.maxY + 20, width: view.frame.width - 40, height: 24)
        
        // Настройка tableView
        tableView.frame = CGRect(x: 0, y: informationsTextLabel.frame.maxY + 10, width: view.frame.width, height: view.frame.height - informationsTextLabel.frame.maxY - 10)
        tableView.dataSource = self
        tableView.register(CharacterDetailCell.self, forCellReuseIdentifier: "CharacterDetailCell")
    }
    
    private func loadCharacterDetails() {
        guard let episode = episode else { return }
        
        guard let randomCharacterURLString = episode.characters.randomElement(),
              let url = URL(string: randomCharacterURLString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Character.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch character: \(error)")
                }
            }, receiveValue: { [weak self] character in
                self?.updateUI(with: character)
            })
            .store(in: &cancellables)
    }
    
    private func updateUI(with character: Character) {
        DispatchQueue.main.async { [weak self] in
            self?.characterNameLabel.text = character.name ?? "Unknown"
            self?.characterDetails = [
                ("Gender", character.gender),
                ("Status", character.status),
                ("Species", character.species),
                ("Origin", character.origin?.name),
                ("Type", character.type),
                ("Location", character.location?.name)
            ]
            self?.tableView.reloadData()
            
            if let imageURLString = character.image, let imageURL = URL(string: imageURLString) {
                self?.imageView.loadImage(from: imageURL)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] image in
                        self?.imageView.image = image
                    }
                    .store(in: &self!.cancellables)
            }
        }
    }
    
    @objc private func changePhotoTapped() {
        photoChangeHandler.handleChangePhotoTapped()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characterDetails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterDetailCell", for: indexPath) as! CharacterDetailCell
        let detail = characterDetails[indexPath.row]
        cell.titleLabel.text = detail.title
        cell.valueLabel.text = detail.value ?? "Unknown"
        return cell
    }
}

extension UIImageView {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in
                UIImage(data: data)
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
