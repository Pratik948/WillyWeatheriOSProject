//
//  TMDB.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 17/11/20.
//

import Foundation

final class TMDB {

    private struct API {
        static let apiKey: String = "4524dbe1cb31c1afbf85b85e0f8963c2"
        static let baseURL: String = "https://api.themoviedb.org/3/"
        static let defaultParams: [String:Any] = ["api_key" : apiKey]
        
        private static let list: String = "list"
        private static let genre: String = "genre/"
        private static let movie: String = "movie/"
        private static let nowPlaying: String = "now_playing"
        
        static let movieGenre: String = baseURL + genre + movie + list
        static let nowPlayingMovies: String = baseURL + movie + nowPlaying
        
    }
    
    static let sharedDB: TMDB = TMDB()
    private init() {}
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
}


extension TMDB {
    public func getMovieGenres(completion: @escaping(Result<MovieGenreList, Error>)->Swift.Void) {
        NetworkManager.request(.get, url: API.movieGenre, parameters: API.defaultParams, completion: completion)
    }
    
    private func getMovies<T:Decodable>(urlString: String, params:[String:Any], completion: @escaping(Result<T, Error>)->Swift.Void) {
        let params = params.merging(API.defaultParams) { (_, new) -> Any in
            new
        }
        NetworkManager.request(.get, url: urlString, parameters: params, completion: completion)
    }
    
    func getNowPlayingMovies(page: Int, completion: @escaping(Result<NowPlayingMovies, Error>)->Swift.Void) {
        getMovies(urlString: API.nowPlayingMovies, params: ["page":page], completion: completion)
    }
    
}
