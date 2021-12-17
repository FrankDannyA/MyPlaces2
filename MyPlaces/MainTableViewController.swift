//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Даниил Франк on 17.12.2021.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    let restarauntNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Bonsai", "Burger Heroes", "Kitchen", "Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy", "X.O" ]

    override func viewDidLoad() {
        super.viewDidLoad()
            
        }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return restarauntNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.imageView?.image = UIImage(named: restarauntNames[indexPath.row])
        cell.textLabel?.text = restarauntNames[indexPath.row]
        
        return cell
    }
    

    
    // MARK: - Navigation


}
