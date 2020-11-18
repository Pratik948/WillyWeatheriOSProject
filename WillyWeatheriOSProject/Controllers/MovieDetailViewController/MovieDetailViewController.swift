//
//  MovieDetailViewController.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 18/11/20.
//

import UIKit
import RealmSwift

class MovieDetailViewController: BaseViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private enum MovieDetailSections {
        case backdrop
        case description
    }

    var movie: Movie? {
        didSet {
            DispatchQueue.main.async {
                self.fillSection()
            }
        }
    }
    private var genre: MovieGenreList?
    private lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black
        tableView.register(UINib.init(nibName: "MovieDetailBackdropTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieDetailBackdropTableViewCell")
        tableView.register(UINib.init(nibName: "MovieDetailOverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieDetailOverviewTableViewCell")
        return tableView
    } ()
    
    private var detailSections: [MovieDetailSections] = []
    
    convenience init(movie: Movie) {
        self.init()
        self.movie = movie
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setupView()
        loadData()
        fillSection()
    }

}

extension MovieDetailViewController {
    
    //MARK: Private functions
    
    private func setAppearance() {
        view.backgroundColor = .black
        title = movie?.title ?? ""
    }

    private func setupView() {
        view.addSubview(tableView)
        tableView.edges(to: view)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fillSection() {
        detailSections.removeAll()
        detailSections.append(.backdrop)
        if (movie?.overview?.trimmingCharacters(in: .whitespaces).count ?? 0) > 0 {
            detailSections.append(.description)
        }
        tableView.reloadData()
    }
    
    private func loadData() {
        let realm = try? Realm()
        genre = realm?.object(ofType: MovieGenreList.self, forPrimaryKey: "staticPrimaryValue")
    }
    
}


extension MovieDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        detailSections.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch detailSections[indexPath.row] {
        case .backdrop:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailBackdropTableViewCell", for: indexPath) as! MovieDetailBackdropTableViewCell
            cell.titleLabel.text = movie?.title
            cell.ratingLabel.text = String.init(format: "Rating: %.2f", (movie?.voteAverage.value ?? 0.0))
            if let posterPath = movie?.backdropPath, let url = URL.init(string: TMDB.imageBaseURL + posterPath) {
                cell.backdropImageView.setImage(from: url)
            }
            else {
                cell.backdropImageView.image = nil
            }
            if let posterPath = movie?.posterPath, let url = URL.init(string: TMDB.imageBaseURL + posterPath) {
                cell.posterImageView.setImage(from: url)
            }
            else {
                cell.posterImageView.image = nil
            }
            let genreIds: [Int] = movie?.genreIds.compactMap { $0 } ?? []
            let genres:[Genre] = self.genre?.genres.filter("id IN %@", genreIds).compactMap { $0 } ?? []
            cell.genreLabel.text = genres.compactMap { $0.name }.joined(separator: ", ")
            cell.genreLabel.isHidden = (cell.genreLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0) == 0
            return cell
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailOverviewTableViewCell", for: indexPath) as! MovieDetailOverviewTableViewCell
            cell.descriptionLabel.text = movie?.overview
            return cell
        }
    }
}


extension MovieDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
