//
//  Plants.swift
//  Plants
//
//  Created by Mirko Poli on 15/06/20.
//  Copyright © 2020 Mirko Poli. All rights reserved.
//

import Foundation

struct Plants: Codable {
    let id: Int
    let link: String
    let scientificName: String
    
    enum CodingKeys: String, CodingKey{
        case id
        case link
        case scientificName = "scientific_name"
    }
    
    init(id: Int, link: String, scientificName: String) {
        self.id = id
        self.link = link
        self.scientificName = scientificName
    }
}
