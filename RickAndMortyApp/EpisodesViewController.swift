//
//  EpisodesViewController.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 27.07.2024.
//

import UIKit
import Combine

class EpisodesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    private var collectionView: UICollectionView!
    private var episodes: [Episode] = []
    private var allEpisodes: [Episode] = []
    private var selectedFilter: FilterType = .episodeNumber
    private let refreshControl = UIRefreshControl()
    private let searchBar = UISearchBar()
    private let filterButton = UIButton(type: .system)
    private var cancellables = Set<AnyCancellable>()
    private var imageCache: [String: String] = [:]
    
    private enum FilterType: String, CaseIterable {
        case characterName = "Character Name"
        case episodeNumber = "Episode Number"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupSearchBar()
        setupFilterButton()
        setupCollectionView()
        
        fetchEpisodes()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Name or episode (ex.S01E01)..."
        
        searchBar.frame = CGRect(x: 20 + 2, y: view.safeAreaInsets.top + 60, width: view.frame.width - 40 - 4, height: 60)
        
        searchBar.setSearchFieldBackgroundColor(.clear)
        searchBar.setSearchFieldBorderColor(.gray)
        
        view.addSubview(searchBar)
        
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.layer.cornerRadius = 8
            searchTextField.clipsToBounds = true
            searchTextField.font = UIFont.systemFont(ofSize: 18)
            searchTextField.textAlignment = .center
            searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.2)
            searchTextField.layer.borderWidth = 1
            searchTextField.layer.borderColor = UIColor.systemGray.cgColor
        }
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.leftView = nil
        searchBar.searchTextField.rightView = nil
    }
    
    
    private func setupFilterButton() {
        guard let filterButtonImage = UIImage(named: "filter") else {
            print("Изображение не найдено")
            return
        }
        
        let resizedImage = resizeImage(image: filterButtonImage, targetSize: CGSize(width: 20, height: 20))
        filterButton.setImage(resizedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        let attributedTitle = NSAttributedString(string: "ADVANCED FILTERS", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 16)
        ])
        filterButton.setAttributedTitle(attributedTitle, for: .normal)
        filterButton.addTarget(self, action: #selector(showFilterOptions), for: .touchUpInside)
        //        filterButton.layer.borderWidth = 1
        
        filterButton.frame = CGRect(x: 30, y: searchBar.frame.maxY + 10, width: view.frame.width - 60, height: 60)
        filterButton.layer.cornerRadius = 8
        filterButton.backgroundColor = .systemBlue2
        filterButton.contentHorizontalAlignment = .center
        
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -70, bottom: 0, right: 70)
        filterButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        view.addSubview(filterButton)
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }
    
    @objc private func showFilterOptions() {
        let alert = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
        for filter in FilterType.allCases {
            alert.addAction(UIAlertAction(title: filter.rawValue, style: .default, handler: { _ in
                self.selectedFilter = filter
                self.updateSearchBarPlaceholder()
                self.searchBar(self.searchBar, textDidChange: self.searchBar.text ?? "")
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }


    
    private func updateSearchBarPlaceholder() {
        searchBar.placeholder = selectedFilter == .characterName ? "Search by character name" : "Search by episode number"
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 48, height: 320)
        layout.minimumLineSpacing = 40
        
        let safeAreaInsets = view.safeAreaInsets
        collectionView = UICollectionView(frame: CGRect(x: 0, y: filterButton.frame.maxY + 8, width: view.frame.width, height: view.frame.height - filterButton.frame.maxY - 8 - safeAreaInsets.bottom), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EpisodeCell.self, forCellWithReuseIdentifier: "EpisodeCell")
        collectionView.backgroundColor = .white
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshEpisodes), for: .valueChanged)
        
        view.addSubview(collectionView)
    }
    
    @objc private func refreshEpisodes() {
        fetchEpisodes()
    }
    
    private func fetchEpisodes() {
        let url = URL(string: "https://rickandmortyapi.com/api/episode")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: EpisodesResponse.self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching episodes: \(error)")
                }
            }, receiveValue: { [weak self] response in
                self?.allEpisodes = response.results
                self?.episodes = self?.allEpisodes ?? []
                
                // Apply initial sorting if needed
                switch self?.selectedFilter {
                case .characterName:
                    self?.sortEpisodesByName()
                case .episodeNumber:
                    self?.sortEpisodesByNumber()
                default:
                    break
                }
                
                self?.collectionView.reloadData()
                self?.refreshControl.endRefreshing()
            })
            .store(in: &cancellables)
    }

    private func sortEpisodesByNumber() {
        episodes.sort { $0.episode < $1.episode }
    }

    private func sortEpisodesByName() {
        episodes.sort { $0.name < $1.name }
    }


    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.item]
        
        let episodeIdAsString = String(episode.id)
        if let imageURL = imageCache[episodeIdAsString] {
            cell.configure(with: episode, imageURL: imageURL)
        } else {
            loadRandomCharacterImage(for: episode) { imageURL in
                if let imageURL = imageURL {
                    self.imageCache[episodeIdAsString] = imageURL
                    DispatchQueue.main.async {
                        cell.configure(with: episode, imageURL: imageURL)
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episode = episodes[indexPath.item]
        let detailsVC = CharacterDetailsViewController()
        detailsVC.episode = episode
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            episodes = allEpisodes
        } else {
            episodes = allEpisodes.filter { episode in
                switch selectedFilter {
                case .characterName:
                    return episode.characters.contains { $0.lowercased().contains(searchText.lowercased()) }
                case .episodeNumber:
                    return episode.episode.lowercased().contains(searchText.lowercased())
                }
            }
        }
        
        switch selectedFilter {
        case .characterName:
            sortEpisodesByName()
        case .episodeNumber:
            sortEpisodesByNumber()
        }
        
        collectionView.reloadData()
    }

    
    private func loadRandomCharacterImage(for episode: Episode, completion: @escaping (String?) -> Void) {
        guard let randomCharacterURLString = episode.characters.randomElement(),
              let randomCharacterURL = URL(string: randomCharacterURLString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: randomCharacterURL) { (data, response, error) in
            if let data = data {
                DispatchQueue.global(qos: .background).async {
                    do {
                        let character = try JSONDecoder().decode(Character.self, from: data)
                        DispatchQueue.main.async {
                            completion(character.image)
                        }
                    } catch {
                        print("Failed to decode character JSON: \(error)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            } else if let error = error {
                print("Failed to fetch character data: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
}

extension UISearchBar {
    func setSearchFieldBackgroundColor(_ color: UIColor) {
        if let searchTextField = self.value(forKey: "searchField") as? UITextField {
            searchTextField.backgroundColor = color
        }
    }
    
    func setSearchFieldBorderColor(_ color: UIColor) {
        if let searchTextField = self.value(forKey: "searchField") as? UITextField {
            searchTextField.layer.borderColor = color.cgColor
            searchTextField.layer.borderWidth = 1.0
            searchTextField.layer.cornerRadius = 2.0
            searchTextField.layer.masksToBounds = true
        }
    }
}
