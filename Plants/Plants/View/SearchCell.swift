//
//  SearchCell.swift
//  Plants
//
//  Created by Mirko Poli on 15/06/20.
//  Copyright © 2020 Mirko Poli. All rights reserved.
//

import UIKit

internal final class SearchCell: UITableViewCell, Cell {
    
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var starredButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    //TODO: set image for Button Checked and Unchecked
    
    var fav: Bool?
    var star: Bool?
    var plant: Plants?
    
    weak var delegate : SearchCellDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()
        plantName.text = nil
        starredButton.isSelected = false
        favoriteButton.isSelected = false
        
        
    }
    
    @IBAction func starredButtonTapped(_ sender: Any) {
        if let star = star, let delegate = delegate, let plant = plant {
            print("Star Touched")
            self.delegate?.searchCell(self, starButtonTapped: star, plant: plant)
            starredButton.isSelected = !(starredButton.isSelected)
        }
    }
    @IBAction func favorite(_ sender: Any) {
        if let fav = fav, let delegate = delegate, let plant = plant {
            print("Favorite Touched")
            self.delegate?.searchCell(self, favButtonTapped: fav, plant: plant)
            favoriteButton.isSelected = !(favoriteButton.isSelected)
        }
    }
}

protocol SearchCellDelegate: AnyObject {
    func searchCell(_ searchCell: SearchCell, favButtonTapped fav: Bool, plant: Plants)
    func searchCell(_ searchCell: SearchCell, starButtonTapped star: Bool, plant: Plants)
}

