//
//  LocationManager.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 27.1.23..
//

import Foundation
import MapKit
import CoreLocation

class MapManager {
    
    static let shared = MapManager()
    
    let locationManager = CLLocationManager()
    
    var annotations: [MKAnnotation] = []
    
    var mapRegion : MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    var selectedLocation: Location? = nil
    var foundedDirections: [MKDirections] = []
    
    func resetMapView(map: MKMapView, directions: MKDirections) {
        map.removeOverlays(map.overlays)
        foundedDirections.append(directions)
        let _ = foundedDirections.map { $0.cancel() }
        foundedDirections.removeAll()
    }
    
    func createDirectionsRequest(transportType: MKDirectionsTransportType,
                                 startCoordinate: CLLocationCoordinate2D,
                                 destinationCoordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let start                         = MKPlacemark(coordinate: startCoordinate)
        let destination                   = MKPlacemark(coordinate: destinationCoordinate)
        
        let request                       = MKDirections.Request()
        request.source                    = MKMapItem(placemark: start)
        request.destination               = MKMapItem(placemark: destination)
        request.transportType             = transportType
        request.requestsAlternateRoutes   = true
        
        return request
    }
    
    // MARK: - Update Map Region
    func updateMapRegion(map: MKMapView, location: Location) {
        mapRegion = MKCoordinateRegion(center: getCoordinates(location: location),
                                       span: mapSpan)
        DispatchQueue.main.async {
            map.setRegion(self.mapRegion, animated: true)
        }
    }
    
    func checkLocationServices(map: MKMapView) {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.checkLocationAuth(map: map)
            } else {
                // Alert to turn it on
            }
        }
    }
    
    // MARK: - Check Auth Status
    func checkLocationAuth(map: MKMapView) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            // Alert for restricted
            break
        case .denied:
            // Alert how to turn on permissions
            break
        case .authorizedAlways, .authorizedWhenInUse:
            map.showsUserLocation = true
            if let location = getUserLocation() {
                updateMapRegion(map: map, location: location)
            }
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Current User Location
    func getUserLocation() -> Location? {
        if let location = locationManager.location?.coordinate {
            let selectedLocation = Location(name: "You", latitude: location.latitude, longitude: location.longitude)
            return selectedLocation
        } else {
            return nil
        }
    }
    
    // MARK: - Get Coordinates for Location
    func getCoordinates(location: Location) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
}
