//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Даниил Франк on 17.12.2021.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    //var places = Place.getPlaces()

    override func viewDidLoad() {
        super.viewDidLoad()
            
        }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return places.count
//    }

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
//
//        let place = places[indexPath.row]
//
//        cell.nameLabel.text = place.name
//        cell.locationLabel.text = place.location
//        cell.typeLabel.text = place.type
//
//
//        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
//        cell.imageOfPlace.clipsToBounds = true
//
//        if place.image == nil {
//            cell.imageOfPlace.image = UIImage(named: place.restaraunrImage!)
//        } else {
//            cell.imageOfPlace.image = place.image
//        }
//
//        return cell
//    }
    
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    
    // MARK: - Navigation

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        
        newPlaceVC.saveNewPlace()
        //places.append(newPlaceVC.newPlace!)
        tableView.reloadData()
    }

}
