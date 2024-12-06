//
//  FavouritesViewController.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 27.07.2024.
//

import UIKit
import Combine

class FavouritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private var collectionView: UICollectionView!
    private var favouriteEpisodes: [Episode] = []
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupCollectionView()
        fetchFavourites()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 150)
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EpisodeCell.self, forCellWithReuseIdentifier: "EpisodeCell")
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteEpisodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        let episode = favouriteEpisodes[indexPath.item]
        
        loadRandomCharacterImage(for: episode)
            .receive(on: DispatchQueue.main)
            .sink { imageURL in
                cell.configure(with: episode, imageURL: imageURL)
            }
            .store(in: &cancellables)
        
        return cell
    }
    
    func updateFavourites(with episodes: [Episode]) {
        favouriteEpisodes = episodes
        collectionView.reloadData()
    }
    
    private func fetchFavourites() {
        let favouriteIDs = UserDefaults.standard.array(forKey: "FavouriteEpisodes") as? [Int] ?? []
        let url = URL(string: "https://rickandmortyapi.com/api/episode")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: EpisodesResponse.self, decoder: JSONDecoder())
            .map { response in
                response.results.filter { favouriteIDs.contains($0.id) }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching favourites: \(error)")
                }
            }, receiveValue: { [weak self] episodes in
                self?.updateFavourites(with: episodes)
            })
            .store(in: &cancellables)
    }
    
    private func loadRandomCharacterImage(for episode: Episode) -> AnyPublisher<String?, Never> {
        guard let randomCharacterURLString = episode.characters.randomElement(),
              let randomCharacterURL = URL(string: randomCharacterURLString) else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: randomCharacterURL)
            .map(\.data)
            .decode(type: Character.self, decoder: JSONDecoder())
            .map { $0.image }
            .catch { _ in Just(nil) }
            .eraseToAnyPublisher()
    }
}
