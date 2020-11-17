//
//  Genre.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 17/11/20.
//

import Foundation
import RealmSwift

@objcMembers
class Genre: Object, Decodable {
    dynamic var id: Int = 0
    dynamic var name: String?
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
   
    override init() {
        super.init()
    }
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.name = try values.decodeIfPresent(String.self, forKey: .name)
    }
}

@objcMembers
class MovieGenreList: Object, Decodable {
    let genres: List<Genre> = List<Genre>()
    dynamic var primaryKeyField: String = "staticPrimaryValue"
    
    enum CodingKeys: String, CodingKey {
        case genres
    }
    
    override class func primaryKey() -> String? {
        "primaryKeyField"
    }
    
    override init() {
        super.init()
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let genres = try values.decodeIfPresent([Genre].self, forKey: .genres) ?? []
        self.genres.append(objectsIn: genres)
    }
    
}
