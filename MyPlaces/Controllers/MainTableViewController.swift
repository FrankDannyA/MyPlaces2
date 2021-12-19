//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Даниил Франк on 17.12.2021.
//

import UIKit
import RealmSwift

class MainTableViewController: UITableViewController {
    
    var places: Results<Place>!
    var ascendingSorting = true
    
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    @IBOutlet weak var reverseSortingButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
            
        places = realm.objects(Place.self)
        
        }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reverseSorting(_ sender: Any) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reverseSortingButton.image = UIImage(systemName: "arrow.up.arrow.down.circle")
        } else {
            reverseSortingButton.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        }
        
        sorting()
    }
    
    private func sorting(){
        
        if segmentedControll.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            let newPlaceVc = segue.destination as! NewPlaceTableViewController
            newPlaceVc.currentPlace = place
        }
    }

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }

}
