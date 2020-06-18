//
//  FavoriteViewController.swift
//  Plants
//
//  Created by Mirko Poli on 17/06/20.
//  Copyright © 2020 Mirko Poli. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class MyPotViewController: UIViewController {
    
    //MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    var dataController: DataController!
    var predicate: NSPredicate!
    var navTitle: String!
    
    var fetchedResultsController:NSFetchedResultsController<Plant>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Plant> = Plant.fetchRequest()
        print("predicate:")
        print(predicate)
        fetchRequest.predicate = predicate
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
        navigationItem.title = navTitle
        
        setupFetchedResultsController()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.delegate
     }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
}

//MARK:- TableView
extension MyPotViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let plant = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = plant.scientificName
        
        return cell

    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plant = fetchedResultsController.object(at: indexPath)
        PlantsClient.getPlantInfo(id: plant.id) { (response, error) in
            if let response = response {
                for link in response {
                    print(link)
                }
            }
        }
        
    }*/
    
    //TODO: pass dataController in SearchViewController to can cancel rows here
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plantToDelete = fetchedResultsController.object(at: indexPath)
            if navTitle == "Favorite" {
                if plantToDelete.starred == false {
                    print("Remove start")
                    dataController.viewContext.delete(plantToDelete)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print("Remove complete")
                } else {
                    plantToDelete.favorite = false
                    print("Update complete")
                }
            } else {
                if plantToDelete.favorite == false {
                    print("Remove start")
                    dataController.viewContext.delete(plantToDelete)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print("Remove complete")
                } else {
                    plantToDelete.starred = false
                    print("Update complete")
                }
            }
            try? dataController.viewContext.save()
        }
    }*/

    
    
}

//MARK:- FetchedResultsController
extension MyPotViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
}

extension MyPotViewController: UINavigationControllerDelegate {
    
}

