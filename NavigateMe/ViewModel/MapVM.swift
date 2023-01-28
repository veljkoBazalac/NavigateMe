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
    
    var selectedTransitMode: MKDirectionsTransportType = .walking
    
    // MARK: - Drop Pin
    func dropPin(tap: UITapGestureRecognizer, map: MKMapView, completion: () -> Void) {
        // Position on the screen, CGPoint
        let screenPoint = tap.location(in: map)
        // Position on the map, CLLocationCoordinate2D
        let coordinate = map.convert(screenPoint, toCoordinateFrom: map)
        
        let location = Location(name: "Selected Pin", latitude: coordinate.latitude, longitude: coordinate.longitude)
        mapManager.selectedLocation = location
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = location.name
        map.removeAnnotations(mapManager.annotations)
        mapManager.annotations.append(annotation)
        map.addAnnotation(annotation)
        
        mapManager.updateMapRegion(map: map, location: location)
        
        completion()
    }
    
    // MARK: - Save Location
    func saveLocation() {
        print("SAVE")
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
        
        let request = mapManager.createDirectionsRequest(transportType: selectedTransitMode,
                                                         startCoordinate: mapManager.getCoordinates(location: userLocation),
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
