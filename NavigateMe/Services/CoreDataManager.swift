//
//  CoreDataManager.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 28.1.23..
//

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var savedLocations: [LocationEntity] = []
}

// MARK: - Functions
extension CoreDataManager {
    // MARK: - Fetch Locations
    func fetchLocations() {
        do {
            savedLocations = try context.fetch(LocationEntity.fetchRequest())
        } catch let error {
            print("Error Fetching Saved Locations: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Save Location
    func saveLocation(location: Location, completion: () -> Void) {
        let newLocation = LocationEntity(context: context)
        newLocation.name = location.name
        newLocation.isoCode = location.isoCode
        newLocation.latitude = location.latitude
        newLocation.longitude = location.longitude
        
        do {
            try self.context.save()
        } catch let error {
            print("Error Saving to CoreData: \(error.localizedDescription)")
        }
        
        fetchLocations()
        completion()
    }
    
    // MARK: - Delete Saved Location
    func deleteLocation(index: Int, completion: () -> Void) {
        let locationToDelete = savedLocations[index]
        self.context.delete(locationToDelete)
        
        do {
            try self.context.save()
        } catch let error {
            print("Error Deleting from Context: \(error.localizedDescription)")
        }
        
        fetchLocations()
        completion()
    }
}
