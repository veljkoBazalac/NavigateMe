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
    let hapticManager = HapticManager.shared
    
    var keyboardIsShown: Bool = false
    var directionsMode: Bool = false
}

// MARK: - Drop Pin
extension MapVM {
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
                self.hapticManager.vibration(type: .error)
                onError("Can't Find Location", "Please check if you entered right location")
                return
            }
            
            guard let response = response else {
                self.hapticManager.vibration(type: .error)
                onError("Response Error", "Please try again")
                return
            }
            
            guard response.mapItems.count > 0 else {
                self.hapticManager.vibration(type: .error)
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
    func savedLocationPin(map: MKMapView, location: LocationEntity, completion: () -> Void) {
        map.removeAnnotations(mapManager.annotations)
        let coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        mapManager.dropPin(map: map, coordinate: coordinates)
        completion()
    }
}

// MARK: - Right View Functions (Remove, Save, Directions)
extension MapVM {
    // MARK: - Remove Selected Location
    func removeLocation(map: MKMapView, completion: () -> Void) {
        mapManager.foundedDirections.removeAll()
        mapManager.selectedLocation = nil
        map.removeAnnotations(mapManager.annotations)
        map.removeOverlays(map.overlays)
        completion()
    }
    
    // MARK: - Save Location
    func saveLocation(completion: () -> Void) {
        guard let selectedLocation = mapManager.selectedLocation else { return }
        coreDataManager.saveLocation(location: selectedLocation) {
            completion()
        }
    }
    
    // MARK: - Show Directions
    func showDirections(map: MKMapView, completion: @escaping () -> Void) {
        guard let userLocation = mapManager.getUserLocation() else {
            hapticManager.vibration(type: .error)
            print("Cant Get Current User Location.")
            return
        }
        
        guard let selectedLocation = mapManager.selectedLocation else {
            hapticManager.vibration(type: .error)
            print("Cant Get Selected Location.")
            return
        }
        
        let request = mapManager.createDirectionsRequest(startCoordinate: mapManager.getCoordinates(location: userLocation),
                                                         destinationCoordinate: mapManager.getCoordinates(location: selectedLocation))
        let directions = MKDirections(request: request)
        mapManager.resetMapView(map: map, directions: directions)
        
        directions.calculate { [weak self] response, error in
            if let error = error {
                self?.hapticManager.vibration(type: .error)
                print("Directions Error: \(error.localizedDescription)")
            }
            
            guard let response = response else {
                self?.hapticManager.vibration(type: .error)
                print("Response Error.")
                return
            }
            
            for route in response.routes {
                let polyline = route.polyline
                map.addOverlay(polyline)
                
                var polyRect = polyline.boundingMapRect
                let verticalPadding = polyRect.size.width * 0.5
                let horizontalPadding = polyRect.size.height * 0.5
                
                polyRect.size.width += verticalPadding
                polyRect.size.height += horizontalPadding
                
                polyRect.origin.x -= verticalPadding / 2
                polyRect.origin.y -= horizontalPadding / 2
                
                map.setVisibleMapRect(polyRect, animated: true)
                completion()
            }
        }
    }
}

// MARK: - Navigation
extension MapVM {
    // MARK: - Calculate Distance from User Location to Selected Location
    func calculateDistance(start: Location, destination: Location, completion: (_ distanceString: String) -> Void) {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let destLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let distance = Double(startLocation.distance(from: destLocation))
        
        if distance < 1000 {
            let distanceString = String(format: "%.0f m", distance)
            completion(distanceString)
        } else {
            let distanceInKM = distance / 1000
            let distanceString = String(format: "%.1f km", distanceInKM)
            completion(distanceString)
        }
    }
    
    // MARK: - Calculate Destination Angle for Arrow based on Current User Location
    func calculateAnnotationDegree(heading: CLLocationDirection, start: Location, destination: Location) -> CGFloat{
        let startCoordinates = CLLocationCoordinate2D(latitude: start.latitude, longitude: start.longitude)
        let destCoordinates = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
        let coordinatesAngleDifference = Float(startCoordinates.heading(to: destCoordinates))
        let headingFloat = Float(heading)
        
        if headingFloat < coordinatesAngleDifference {
            return CGFloat(coordinatesAngleDifference - headingFloat)
        } else {
            return CGFloat(-(headingFloat - coordinatesAngleDifference))
        }
    }
}
