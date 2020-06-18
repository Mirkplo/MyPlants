//
//  ViewController.swift
//  Plants
//
//  Created by Mirko Poli on 14/06/20.
//  Copyright © 2020 Mirko Poli. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var noPlantLabel: UILabel!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Plant>!
    
    var plantsList: [Plants]?
    
    //MARK:- UserDefaults
    func retrieveSearching(){
        if let startSearching = UserDefaults.standard.value(forKey: "searching"){
            searchBar.text = startSearching as? String
        } else {
            searchBar.text = ""
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveSearching()
        setupFetchedResultsController()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        loading(false)
        noPlant(false)
        
        plantsList = []
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(searchBar.text, forKey: "searching")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.standard.set(searchBar.text, forKey: "searching")
        fetchedResultsController = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func loading(_ isLoading: Bool) {
        searchBar.showsSearchResultsButton = isLoading
        loadingView.isHidden = !isLoading
    }
    
    func noPlant(_ noPlantFound: Bool){
        tableView.isHidden = noPlantFound
        noPlantLabel.isHidden = !noPlantFound
    }
    
    //MARK:- Show Alert
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MyPotViewController {
            vc.dataController = dataController
            switch segue.identifier {
            case "favSegue":
                vc.predicate = NSPredicate(format: "favorite == true")
                vc.navTitle = "Favorite"
            case "starSegue":
                vc.predicate = NSPredicate(format: "starred == true")
                vc.navTitle = "My Plants"
            default:
                print("Error in segue")
            }
        }
    }
}

//MARK: - TableView
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Inside tableView, plantsList.count = \(plantsList?.count)")
        return plantsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let plant = plantsList?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        
        cell.plant = plant

        setupFetchedResultsController()
        if let result = fetchedResultsController.fetchedObjects {
            var found = false
            for plantSelected in result {
                if plantSelected.scientificName == plant?.scientificName {
                    cell.fav = plantSelected.favorite
                    cell.favoriteButton.isSelected = plantSelected.favorite
                    cell.star = plantSelected.starred
                    cell.starredButton.isSelected = plantSelected.starred
                    found = true
                }
            }
            if !found{
                cell.fav = false
                cell.star = false
            }
        }
        cell.plantName.text = plant?.scientificName
        cell.delegate = self
        
        return cell

    }
    
    
}

//MARK: - FetchedResults
extension SearchViewController: NSFetchedResultsControllerDelegate {
    
}

//MARK: - SearchBar
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.loading(true)
        }
        plantsList = []
        if let text = searchBar.text {
            var nameEncoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            PlantsClient.getPlants(name: nameEncoded ?? "") { (response, error) in
                if let response = response {
                    for one in response {
                        let plant = Plants(id: one.id, link: one.link, scientificName: one.scientificName)
                        self.plantsList?.append(plant)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Connection Failed", message: error?.localizedDescription ?? "No information about")
                    }
                }
                DispatchQueue.main.async {
                    print("TableView Reloaded")
                    print("plantList.count = \(self.plantsList?.count)")
                    if self.plantsList?.count == 0 {
                        self.noPlant(true)
                    } else {
                        self.noPlant(false)
                    }
                    self.loading(false)
                    self.tableView.reloadData()
                    self.searchBar.resignFirstResponder()
                    
                }
                
            }
        }
    }
}

extension SearchViewController : SearchCellDelegate {
    func searchCell(_ searchCell: SearchCell, favButtonTapped fav: Bool, plant: Plants) {
        setupFetchedResultsController()
        if !fav {
            if let result = fetchedResultsController.fetchedObjects {
                var found = false
                for plantSelected in result {
                    if plantSelected.scientificName == plant.scientificName {
                        plantSelected.favorite = true
                        found = true
                        print("Update complete")
                    }
                }
                if !found {
                    let plantToCreate = Plant(context: dataController.viewContext)
                    plantToCreate.scientificName = plant.scientificName
                    plantToCreate.id = Int32(plant.id)
                    plantToCreate.link = plant.link
                    plantToCreate.commonName = plant.scientificName
                    
                    plantToCreate.favorite = true
                    plantToCreate.starred = false
                    print("Adding complete")
                    print(plantToCreate)
                }
                try? dataController.viewContext.save()
            }
        } else {
            if let result = fetchedResultsController.fetchedObjects {
                for plantSelected in result {
                    if plantSelected.scientificName == plant.scientificName {
                        plantSelected.favorite = false
                        print("Updating complete")
                        if !plantSelected.starred {
                            dataController.viewContext.delete(plantSelected)
                            print("Removing complete")
                        }
                        try? dataController.viewContext.save()
                    }
                }
            }
        }
        searchCell.fav = !fav
        view.reloadInputViews()
    }
    
    func searchCell(_ searchCell: SearchCell, starButtonTapped star: Bool, plant: Plants) {
        setupFetchedResultsController()
        if !star {
            if let result = fetchedResultsController.fetchedObjects {
                var found = false
                for plantSelected in result {
                    if plantSelected.scientificName == plant.scientificName {
                        plantSelected.starred = true
                        found = true
                        print("Update complete")
                    }
                }
                if !found {
                    let plantToCreate = Plant(context: dataController.viewContext)
                    plantToCreate.scientificName = plant.scientificName
                    plantToCreate.id = Int32(plant.id)
                    plantToCreate.link = plant.link
                    plantToCreate.commonName = plant.scientificName
                    
                    plantToCreate.favorite = false
                    plantToCreate.starred = true
                    print("Adding complete")
                    print(plantToCreate)
                }
                try? dataController.viewContext.save()
            }
        } else {
            if let result = fetchedResultsController.fetchedObjects {
                for plantSelected in result {
                    if plantSelected.scientificName == plant.scientificName {
                        plantSelected.starred = false
                        print("Updating complete")
                        if !plantSelected.favorite {
                            dataController.viewContext.delete(plantSelected)
                            print("Removing complete")
                        }
                        try? dataController.viewContext.save()
                    }
                }
            }
        }
        searchCell.star = !star
    }

}



