//
//  MoviesResults.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 18/11/20.
//

import Foundation
import RealmSwift

@objcMembers
class Movie: Object, Decodable {
    
    dynamic var id:Int = 0
    dynamic var popularity:RealmOptional<Double> = RealmOptional<Double>()
    dynamic var video:Bool = false
    dynamic var adult: Bool = false
    dynamic var title: String?
    dynamic var overview: String?
    dynamic var posterPath: String?
    dynamic var backdropPath: String?
    dynamic var originalLanguage: String?
    dynamic var originalTitle: String?
    dynamic var genreIds: List<Int> = List<Int>()
    dynamic var voteCount:RealmOptional<Double> = RealmOptional<Double>()
    dynamic var voteAverage:RealmOptional<Double> = RealmOptional<Double>()
    dynamic var releaseDate: String?

    override init() {
        super.init()
    }
    enum CodingKeys: String, CodingKey {
        case id, popularity, video, adult, title, overview
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case genreIds = "genre_ids"
        case posterPath = "poster_path"
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        popularity.value = try values.decodeIfPresent(Double.self, forKey: .popularity)
        video = try values.decodeIfPresent(Bool.self, forKey: .video) ?? false
        adult = try values.decodeIfPresent(Bool.self, forKey: .adult) ?? false
        title = try values.decodeIfPresent(String.self, forKey: .title)
        overview = try values.decodeIfPresent(String.self, forKey: .overview)
        posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try values.decodeIfPresent(String.self, forKey: .backdropPath)
        originalLanguage = try values.decodeIfPresent(String.self, forKey: .originalLanguage)
        originalTitle = try values.decodeIfPresent(String.self, forKey: .originalTitle)
        releaseDate = try values.decodeIfPresent(String.self, forKey: .releaseDate)
        voteCount.value = try values.decodeIfPresent(Double.self, forKey: .voteCount)
        voteAverage.value = try values.decodeIfPresent(Double.self, forKey: .voteAverage)
        let genreIds = try values.decodeIfPresent([Int].self, forKey: .genreIds) ?? []
        self.genreIds.append(objectsIn: genreIds)
    }
}

@objcMembers
class NowPlayingMovies: Object, Decodable {
    dynamic var primaryKeyField: String = "nowPlayingMoviesResult"
    
    let results: List<Movie> = List<Movie>()
    
    dynamic var page: RealmOptional<Int> = RealmOptional<Int>()
    dynamic var totalResults: RealmOptional<Int> = RealmOptional<Int>()
    dynamic var totalPages: RealmOptional<Int> = RealmOptional<Int>()
    
    enum CodingKeys: String, CodingKey {
        case results
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
    
    override class func primaryKey() -> String? {
        "primaryKeyField"
    }
    
    override init() {
        super.init()
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let results = try values.decodeIfPresent([Movie].self, forKey: .results) ?? []
        self.results.append(objectsIn: results)
        self.page.value = try values.decodeIfPresent(Int.self, forKey: .page)
        self.totalResults.value = try values.decodeIfPresent(Int.self, forKey: .totalResults)
        self.totalPages.value = try values.decodeIfPresent(Int.self, forKey: .totalPages)
    }
    
}
