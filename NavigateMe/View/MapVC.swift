//
//  ViewController.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 27.1.23..
//

import UIKit
import MapKit
import CoreLocation


class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Map
    let mapView: MKMapView = {
        let map = MKMapView()
        map.showsCompass = false
        return map
    }()
    
    // MARK: - Top View
    let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightText
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let topText: UILabel = {
       let label = UILabel()
        label.text = "Saved Locations"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Right Side View
    let rightView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightText
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 50
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var removeLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .systemRed
        button.setTitle(nil, for: .normal)
        button.clipsToBounds = false
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeLocationPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var saveLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.clipsToBounds = false
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveLocationPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var showDirectionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.triangle.branch"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.clipsToBounds = false
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showDirectionsPressed), for: .touchUpInside)
        return button
    }()
    
    var tapRecognizer = UITapGestureRecognizer()
    var vm = MapVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIElements()
        addGesutures()
        setupLocationManager()
        vm.mapManager.checkLocationServices(map: self.mapView)
    }
    
    private func addGesutures() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)
        
        let showSavedTapped = UITapGestureRecognizer(target: self, action: #selector(showSavedLocationsList))
        topView.addGestureRecognizer(showSavedTapped)
    }
    
    // MARK: - Save Location
    @objc func saveLocationPressed() {
        vm.saveLocation()
    }
    
    // MARK: - Show Directions for Selected Location
    @objc func showDirectionsPressed() {
        vm.showDirections(map: self.mapView) {
            self.topView.isHidden = true
        }
    }
    
    // MARK: - Drop Pin on Map
    @objc func dropPin(_ gesture: UITapGestureRecognizer) {
        vm.dropPin(tap: self.tapRecognizer, map: self.mapView) {
            self.rightView.isHidden = false
        }
    }
    
    // MARK: - Show Saved Locations List
    @objc func showSavedLocationsList(_ gesture: UITapGestureRecognizer) {
        print("SHOW")
    }
    
    // MARK: - Remove Location Pressed
    @objc func removeLocationPressed() {
        vm.removeLocation(map: self.mapView) {
            self.rightView.isHidden = true
            self.topView.isHidden = false
        }
    }
}

// MARK: - Map and Locations
extension MapVC: CLLocationManagerDelegate, MKMapViewDelegate {
    // MARK: - Setup Location Manager
    func setupLocationManager() {
        mapView.delegate = self
        vm.mapManager.locationManager.delegate = self
        vm.mapManager.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Did Change Authorization Delegate Method
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        vm.mapManager.checkLocationAuth(map: self.mapView)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
}

// MARK: - UI Elements
extension MapVC {
    // MARK: - Set UI Elements
    private func setUIElements() {
        mapView.frame = view.bounds
        view.addSubview(mapView)
        // Top View
        mapView.addSubview(topView)
        topView.addSubview(topText)
        // Right View
        mapView.addSubview(rightView)
        rightView.addSubview(buttonsStack)
        buttonsStack.addArrangedSubview(removeLocationButton)
        buttonsStack.addArrangedSubview(saveLocationButton)
        buttonsStack.addArrangedSubview(showDirectionsButton)
        
        setTopView()
        setRightView()
    }
    
    // MARK: - Set Top View
    func setTopView() {
        topView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 60).isActive = true
        topView.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20).isActive = true
        topView.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        topView.layer.cornerRadius = 10
        
        topText.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        topText.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
    }
    
    // MARK: - Right Side View
    func setRightView() {
        rightView.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20).isActive = true
        rightView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -40).isActive = true
        rightView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        rightView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        rightView.layer.cornerRadius = 10

        buttonsStack.centerXAnchor.constraint(equalTo: rightView.centerXAnchor).isActive = true
        buttonsStack.centerYAnchor.constraint(equalTo: rightView.centerYAnchor).isActive = true
        
        removeLocationButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        removeLocationButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        saveLocationButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        saveLocationButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        showDirectionsButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        showDirectionsButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
}
