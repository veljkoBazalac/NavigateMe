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
    
    var selectedTransportType: MKDirectionsTransportType = .walking
    
    // MARK: - Open Google Maps App
    func openGoogleMaps(location: Location) {
        var transportType: String = ""
        
        if selectedTransportType == .automobile {
            transportType = "driving"
        } else if selectedTransportType == .walking {
            transportType = "walking"
        }
        
        let urlString = "comgooglemaps://?saddr=&daddr=\(location.latitude),\(location.longitude)&directionsmode=\(transportType)"
        
        if UIApplication.shared.canOpenURL(URL(string: urlString)!) {
            UIApplication.shared.open(URL(string: urlString)!)
        }
    }
    
}

// MARK: - Directions
extension MapManager {
    // MARK: - Drop Pin On Map
    func dropPin(map: MKMapView, coordinate: CLLocationCoordinate2D) {
        getAddress(location: CLLocation(latitude: coordinate.latitude,
                                        longitude: coordinate.longitude)) { [weak self] address, iso in
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = address
            
            let location = Location(name: address,
                                    isoCode: iso,
                                    latitude: coordinate.latitude,
                                    longitude: coordinate.longitude)
            self?.selectedLocation = location
            
            self?.annotations.append(annotation)
            map.addAnnotation(annotation)
            
            self?.updateMapRegion(map: map, location: location)
        }
    }
    
    // MARK: - Create Directions Request
    func createDirectionsRequest(startCoordinate: CLLocationCoordinate2D,
                                 destinationCoordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let start                         = MKPlacemark(coordinate: startCoordinate)
        let destination                   = MKPlacemark(coordinate: destinationCoordinate)
        
        let request                       = MKDirections.Request()
        request.source                    = MKMapItem(placemark: start)
        request.destination               = MKMapItem(placemark: destination)
        request.transportType             = self.selectedTransportType
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
    func getAddress(location: CLLocation, completion: @escaping (_ address: String, _ iso: String) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("Error Getting Placemark")
                return
            }
            
            guard let isoCode = placemark.isoCountryCode else {
                print("Cant Get ISO Code for Location.")
                return
            }
            let streetName = placemark.thoroughfare ?? ""
            let streetNumber = placemark.subThoroughfare ?? ""
            
            let address = "\(streetName) \(streetNumber)"
            
            completion(address, self.flag(countryCode: isoCode))
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
    func checkLocationServices(map: MKMapView, onError: @escaping () -> Void) {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.checkLocationAuth(map: map) {
                    onError()
                }
            } else {
                onError()
            }
        }
    }
    
    // MARK: - Check Auth Status
    func checkLocationAuth(map: MKMapView, onError: () -> Void) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            onError()
        case .denied:
            onError()
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
            let selectedLocation = Location(name: "You",
                                            isoCode: "",
                                            latitude: location.latitude,
                                            longitude: location.longitude)
            return selectedLocation
        } else {
            return nil
        }
    }
    
    // MARK: - Get Coordinates for Location
    func getCoordinates(location: Location) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    // MARK: - Flag for Country
    func flag(countryCode: String) -> String {
        let base : UInt32 = 127397
        var codeString = ""
        for code in countryCode.uppercased().unicodeScalars {
            codeString.unicodeScalars.append(UnicodeScalar(base + code.value)!)
        }
        return codeString
    }
}
