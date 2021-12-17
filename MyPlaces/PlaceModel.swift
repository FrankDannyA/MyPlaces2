//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Даниил Франк on 17.12.2021.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaraunrImage: String?
    
    static let restarauntNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Bonsai", "Burger Heroes", "Kitchen", "Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy", "X.O" ]
    
    static func getPlaces() -> [Place] {
        
        var places = [Place]()
        
        for place in restarauntNames {
            places.append(Place(name: place, location: "Темиртау", type: "Кафе",image: nil, restaraunrImage: place))
        }
        
        return places
    }
}
