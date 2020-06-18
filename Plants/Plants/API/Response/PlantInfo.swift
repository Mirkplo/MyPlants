//
//  Families.swift
//  Plants
//
//  Created by Mirko Poli on 14/06/20.
//  Copyright © 2020 Mirko Poli. All rights reserved.
//

import Foundation

struct PlantInfo: Codable {
    let images: [PlantImage?]
}

struct PlantImage: Codable {
    let url: String?
}
