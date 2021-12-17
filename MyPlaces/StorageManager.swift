//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Даниил Франк on 17.12.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place){
        try! realm.write {
            realm.add(place)
        }
    }
}


