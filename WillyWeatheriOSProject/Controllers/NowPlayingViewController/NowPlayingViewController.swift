//
//  NowPlayingViewController.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 18/11/20.
//

import UIKit
import RealmSwift

class NowPlayingViewController: BaseViewController, Pagination {

    var currentPage: Int = 1
    var totalPage: Int = 0
    var apiStatus: ControllerAPIStatus = .completed
    private var movieResultNotificationToken: NotificationToken?
    private var nowPlayingMovies: NowPlayingMovies?
    private var genre: MovieGenreList?
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl.init()
        return refreshControl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "MovieGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.register(UINib.init(nibName: "CollectionViewLoadingFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "CollectionViewLoadingFooterView")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setAppearance()
        loadData()
    }

    deinit {
        movieResultNotificationToken?.invalidate()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate { (context) in
            self.collectionView.collectionViewLayout.invalidateLayout()
        } completion: { (context) in
            
        }

    }
}

extension NowPlayingViewController {
    
    //MARK: Private functions
    
    private func setupViews() {
        view.addSubview(collectionView)
        collectionView.edges(to: view)
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    private func setAppearance() {
        view.backgroundColor = .white
        title = "Now Playing"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func loadData() {
        TMDB.sharedDB.getMovieGenres { (result) in
            switch result {
            case .failure(let err):
                print(err.localizedDescription)
            case .success(let genreList):
                let realm = try? Realm()
                try? realm?.write {
                    realm?.add(genreList, update: .modified)
                }
            }
        }
        let realm = try? Realm()
        nowPlayingMovies = realm?.object(ofType: NowPlayingMovies.self, forPrimaryKey: "nowPlayingMoviesResult")
        genre = realm?.object(ofType: MovieGenreList.self, forPrimaryKey: "staticPrimaryValue")
        observeNewMovies()
        self.getMovies()
    }
    
    private func observeNewMovies() {
        movieResultNotificationToken = nowPlayingMovies?.observe(on: .main, { [weak self] (changes) in
            switch changes {
            case .error(_):
                break
            case .change(let object, _):
                if let object = object as? NowPlayingMovies {
                    self?.currentPage = object.page.value ?? 1
                    self?.totalPage = object.totalPages.value ?? 0
                }
                self?.collectionView.reloadData()
            case .deleted:
                break
            }
        })
    }
    
    private func getMovies() {
        if (self.nowPlayingMovies == nil || currentPage == 1) && !refreshControl.isRefreshing {
            self.refreshControl.beginRefreshing()
        }
        self.apiStatus = .fetching
        TMDB.sharedDB.getNowPlayingMovies(page: currentPage) { (result) in
            self.apiStatus = .completed
            switch result {
            case .failure(let err):
                print(err.localizedDescription)
            case .success(let newMovies):
                let realm = try? Realm()
                if self.currentPage > 1, let nowPlayingMovies = realm?.object(ofType: NowPlayingMovies.self, forPrimaryKey: "nowPlayingMoviesResult") {
                    try? realm?.write {
                        nowPlayingMovies.totalPages = newMovies.totalPages
                        nowPlayingMovies.totalResults = newMovies.totalResults
                        nowPlayingMovies.page = newMovies.page
                        nowPlayingMovies.results.append(objectsIn: newMovies.results)
                        realm?.add(nowPlayingMovies, update: .modified)
                    }
                }
                else {
                    try? realm?.write {
                        realm?.add(newMovies, update: .all)
                    }
                    if self.nowPlayingMovies == nil {
                        DispatchQueue.main.async {
                            self.nowPlayingMovies = realm?.object(ofType: NowPlayingMovies.self, forPrimaryKey: "nowPlayingMoviesResult")
                            self.observeNewMovies()
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    @objc
    private func refreshData(_ sender: UIRefreshControl) {
        self.currentPage = 1
        self.getMovies()
    }
}


extension NowPlayingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        nowPlayingMovies?.results.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = nowPlayingMovies?.results[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovieGridCollectionViewCell
        cell.titleLabel.text = movie?.title
        cell.ratingLabel.text = String.init(format: "Rating: %.2f", (movie?.voteAverage.value ?? 0.0))
        if let posterPath = movie?.posterPath, let url = URL.init(string: TMDB.imageBaseURL + posterPath) {
            LazyImageCache.shared.load(url: url) { (image) in
                cell.posterImageView.image = image
            }
        }
        else {
            cell.posterImageView.image = nil
        }
        let genreIds: [Int] = movie?.genreIds.compactMap { $0 } ?? []
        let genres:[Genre] = self.genre?.genres.filter("id IN %@", genreIds).compactMap { $0 } ?? []
        cell.genreLabel.text = genres.compactMap { $0.name }.joined(separator: ", ")
        cell.genreLabel.isHidden = (cell.genreLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0) == 0
        return cell
    }
    
}

extension NowPlayingViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isPortrait = (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let columnCount: CGFloat = isPortrait ? isIPad ? 6 : 3 : isIPad ? 8 : 4
        let ratio:CGFloat = 750.0/500.0
        let width = collectionView.frame.size.width / columnCount
        return CGSize.init(width: width, height: (width * ratio))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        self.totalPage > self.currentPage ? CGSize.init(width: collectionView.frame.width, height: 40) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewLoadingFooterView", for: indexPath) as! CollectionViewLoadingFooterView
            footerView.spinner.startAnimating()
            return footerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if view.isKind(of: CollectionViewLoadingFooterView.self) && self.apiStatus != .fetching {
            self.currentPage += 1
            self.getMovies()
        }
    }
}
