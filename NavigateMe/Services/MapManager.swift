//
//  MapManager.swift
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
    
    var mapRegion : MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    var annotations: [MKAnnotation] = []
    var selectedLocation: Location? = nil
    var foundedDirections: [MKDirections] = []
}

// MARK: - Directions
extension MapManager {
    // MARK: - Drop Pin On Map
    func dropPin(map: MKMapView, coordinate: CLLocationCoordinate2D) {
        let location = Location(name: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
        selectedLocation = location
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        getAddress(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { address in
            annotation.title = address
        }
        annotations.append(annotation)
        map.addAnnotation(annotation)
        
        updateMapRegion(map: map, location: location)
    }
    
    // MARK: - Create Directions Request
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
    
    // MARK: - Remove directions
    func resetMapView(map: MKMapView, directions: MKDirections) {
        map.removeOverlays(map.overlays)
        foundedDirections.append(directions)
        let _ = foundedDirections.map { $0.cancel() }
        foundedDirections.removeAll()
    }
    
    // MARK: - Get Address
    func getAddress(location: CLLocation, completion: @escaping (_ address: String) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("Error Getting Placemark")
                return
            }
            
            let streetName = placemark.thoroughfare ?? ""
            let streetNumber = placemark.subThoroughfare ?? ""
            let address = "\(streetName) - \(streetNumber)"
            
            completion(address)
        }
    }
}

// MARK: - Location and Map
extension MapManager {
    // MARK: - Update Map Region
    func updateMapRegion(map: MKMapView, location: Location) {
        mapRegion = MKCoordinateRegion(center: getCoordinates(location: location),
                                       span: mapSpan)
        DispatchQueue.main.async {
            map.setRegion(self.mapRegion, animated: true)
        }
    }
    
    // MARK: - Check if Location Services are Enabled
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
