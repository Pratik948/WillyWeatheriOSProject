//
//  NetworkManager.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 17/11/20.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case invalidResponse
    case invalidData
    case decodingError
    case serverError
}

class NetworkManager {
    enum RequestType:String {
        case post = "POST"
        case get = "GET"
    }
    @discardableResult
    class func request<T:Decodable>(_ method:RequestType, url urlString:String, parameters:[String:Any], completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask? {
        var urlComponents = URLComponents.init(string: urlString)
        if method == .get {
            urlComponents?.queryItems = []
            for (key, value) in parameters {
                urlComponents?.queryItems?.append(URLQueryItem.init(name: key, value: "\(value)"))
            }
        }
        guard let url = urlComponents?.url else {
            completion(.failure(NetworkError.badURL))
            return nil
        }
        var request = URLRequest.init(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if method == .post {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            if 200 ... 299 ~= response.statusCode {
                if let data = data {
                    do {
                        let decodedData: T = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decodedData))
                    }
                    catch {
                        completion(.failure(NetworkError.decodingError))
                    }
                } else {
                    completion(.failure(NetworkError.invalidData))
                }
            } else {
                completion(.failure(NetworkError.serverError))
            }
        }
        task.resume()
        return task
    }

}
