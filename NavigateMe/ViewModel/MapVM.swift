//
//  MapVM.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 27.1.23..
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapVM: NSObject {
    
    let mapManager = MapManager.shared
    
    let coreDataManager = CoreDataManager.shared
    
    var keyboardIsShown: Bool = false
    var directionsMode: Bool = false
    
    // MARK: - Drop Pin on User Tap
    func userPlacedPin(tap: UITapGestureRecognizer, map: MKMapView, completion: () -> Void) {
        if directionsMode == false {
            // Position on the screen, CGPoint
            let screenPoint = tap.location(in: map)
            // Position on the map, CLLocationCoordinate2D
            let coordinate = map.convert(screenPoint, toCoordinateFrom: map)
            
            map.removeAnnotations(mapManager.annotations)
            mapManager.dropPin(map: map, coordinate: coordinate)
            
            completion()
        }
    }
    
    // MARK: - Drop Pin on User Search
    func userSearchedPin(map: MKMapView,
                         address: String,
                         onSuccess: @escaping () -> Void,
                         onError: @escaping (_ title: String, _ body: String) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                onError("Can't Find Location", "Please check if you entered right location")
                return
            }
            
            guard let response = response else {
                onError("Response Error", "Please try again")
                return
            }
            
            guard response.mapItems.count > 0 else {
                onError("No locations founded", "Please try again")
                return
            }
            
            map.removeAnnotations(self.mapManager.annotations)
            
            for item in response.mapItems {
                self.mapManager.dropPin(map: map, coordinate: item.placemark.coordinate)
            }
            
            onSuccess()
        }
    }
    
    // MARK: - Drop Pin on Save Location Selected
    func saveLocationSelected(map: MKMapView, location: LocationEntity, completion: () -> Void) {
        map.removeAnnotations(mapManager.annotations)
        let coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        mapManager.dropPin(map: map, coordinate: coordinates)
        completion()
    }
    
    // MARK: - Save Location
    func saveLocation() {
        guard let selectedLocation = mapManager.selectedLocation else {
            print("Select Location")
            return
        }
        coreDataManager.saveLocation(location: selectedLocation)
    }
    
    // MARK: - Show Directions
    func showDirections(map: MKMapView, completion: @escaping () -> Void) {
        guard let userLocation = mapManager.getUserLocation() else {
            print("Cant Get Current User Location.")
            return
        }
        
        guard let selectedLocation = mapManager.selectedLocation else {
            print("Cant Get Selected Location.")
            return
        }
        
        let request = mapManager.createDirectionsRequest(startCoordinate: mapManager.getCoordinates(location: userLocation),
                                                         destinationCoordinate: mapManager.getCoordinates(location: selectedLocation))
        let directions = MKDirections(request: request)
        mapManager.resetMapView(map: map, directions: directions)
        
        directions.calculate { response, error in
            if let error = error {
                print("Directions Error: \(error.localizedDescription)")
            }
            
            guard let response = response else {
                print("Response Error.")
                return
            }
            
            for route in response.routes {
                let polyline = route.polyline
                map.addOverlay(polyline)
                
                var polyRect = polyline.boundingMapRect
                let verticalPadding = polyRect.size.width * 0.25
                let horizontalPadding = polyRect.size.height * 0.25
                
                polyRect.size.width += verticalPadding
                polyRect.size.height += horizontalPadding
                
                polyRect.origin.x -= verticalPadding / 2
                polyRect.origin.y -= horizontalPadding / 2
                
                map.setVisibleMapRect(polyRect, animated: true)
                completion()
            }
        }
    }
    
    // MARK: - Remove Selected Location
    func removeLocation(map: MKMapView, completion: () -> Void) {
        mapManager.foundedDirections.removeAll()
        mapManager.selectedLocation = nil
        map.removeAnnotations(mapManager.annotations)
        map.removeOverlays(map.overlays)
        completion()
    }
}
