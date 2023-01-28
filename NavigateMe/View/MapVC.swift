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
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.showsCompass = false
        map.mapType = .hybrid
        return map
    }()
    
    // MARK: - Loading Indicator
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.tintColor = .darkGray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let searchingText: UILabel = {
        let label = UILabel()
        label.text = "Searching..."
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Top View
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let searchLocationTF: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search Address...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        tf.backgroundColor = .lightText
        tf.tintColor = .darkGray
        tf.textColor = .darkText
        tf.returnKeyType = .search
        tf.layer.cornerRadius = 10
        tf.setLeftPaddingPoints(10)
        tf.setRightPaddingPoints(10)
        return tf
    }()
    
    private lazy var transportTypeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        button.tintColor = .systemOrange
        button.setTitle(nil, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changeTransportTypePressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var showSavedLocationsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark.circle.fill"), for: .normal)
        button.tintColor = .systemOrange
        button.setTitle(nil, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showSavedLocationsList), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Saved Locations
    private let savedView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - Right Side View
    private let rightView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 50
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var removeLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .systemRed
        button.setTitle(nil, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeLocationPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.tintColor = .systemOrange
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveLocationPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var showDirectionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.triangle.branch"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.tintColor = .systemOrange
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showDirectionsPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Left Side View
    private let leftView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var googleMapsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "googleMaps"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openGoogleMaps), for: .touchUpInside)
        return button
    }()
    
    var tapRecognizer = UITapGestureRecognizer()
    var vm = MapVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear),
                                               name: UIApplication.keyboardWillShowNotification,
                                               object: nil)
        setUIElements()
        addGesutures()
        setupLocationManager()
        vm.mapManager.checkLocationServices(map: self.mapView)
        vm.coreDataManager.fetchLocations()
    }
    
    // MARK: - Detect When Keyboard is Shown
    @objc func keyboardWillAppear() {
        vm.keyboardIsShown = true
    }
}

// MARK: - Map Selection Functions
extension MapVC {
    // MARK: - Add Gesture Recognizer to Map
    private func addGesutures() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(userPlacedPinOnMap))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - User Placed Pin on Map
    @objc func userPlacedPinOnMap(_ gesture: UITapGestureRecognizer) {
        vm.userPlacedPin(tap: self.tapRecognizer, map: self.mapView) {
            self.rightView.isHidden = false
            self.leftView.isHidden = false
            self.view.endEditing(true)
        }
    }
}

// MARK: - Top View Buttons Action
extension MapVC {
    // MARK: - Change Transport Type
    @objc func changeTransportTypePressed() {
        if vm.mapManager.selectedTransportType == .walking {
            vm.mapManager.selectedTransportType = .automobile
            transportTypeButton.setImage(UIImage(systemName: "car.fill"), for: .normal)
        } else if vm.mapManager.selectedTransportType == .automobile {
            vm.mapManager.selectedTransportType = .walking
            transportTypeButton.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        }
    }
    
    // MARK: - Show Saved Locations List
    @objc func showSavedLocationsList() {
        if vm.coreDataManager.savedLocations.isEmpty {
            AlertView.shared.addAlert(vc: self, title: "No Saved Locations", body: "")
        } else {
            let vc = SelectLocationVC()
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
}

// MARK: - Right & Left View Buttons Action
extension MapVC {
    // MARK: - Remove Location Pressed
    @objc func removeLocationPressed() {
        vm.removeLocation(map: self.mapView) {
            self.rightView.isHidden = true
            self.leftView.isHidden = true
            self.topView.isHidden = false
            
            if vm.directionsMode == true {
                self.showDirectionsButton.setImage(UIImage(systemName: "arrow.triangle.branch"), for: .normal)
                self.showDirectionsButton.tintColor = .systemOrange
                self.vm.directionsMode = false
            }
        }
    }
    
    // MARK: - Save Location
    @objc func saveLocationPressed() {
        vm.saveLocation()
    }
    
    // MARK: - Show Directions for Selected Location
    @objc func showDirectionsPressed() {
        if vm.directionsMode == false {
            vm.showDirections(map: self.mapView) {
                self.topView.isHidden = true
                self.vm.directionsMode = true
                self.showDirectionsButton.setImage(UIImage(systemName: "location.north.circle.fill"), for: .normal)
                self.showDirectionsButton.tintColor = .systemBlue
            }
        } else {
            //TODO: OPEN AND USE NAVIGATION COMPAS ARROW
            print("NAVIGATE")
        }
    }
    
    // MARK: - Open Google Maps
    @objc private func openGoogleMaps() {
        if let location = vm.mapManager.selectedLocation {
            vm.mapManager.openGoogleMaps(location: location)
        }
    }
}

// MARK: - Go To Saved Location Delegate
extension MapVC: GoToSavedLocationDelegate {
    func didSelectSavedLocation(location: LocationEntity) {
        vm.saveLocationSelected(map: self.mapView, location: location) {
            self.rightView.isHidden = false
            self.leftView.isHidden = false
        }
    }
}

// MARK: - Search TextField
extension MapVC: UITextFieldDelegate, MKLocalSearchCompleterDelegate {
    // MARK: - Search for Location
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard
            let address = textField.text,
            textField.text != "" else {
            self.view.endEditing(true)
            AlertView.shared.addAlert(vc: self, title: "Empty Textfield", body: "Search Textfield can NOT be empty")
            return false
        }
        
        view.isUserInteractionEnabled = false
        self.view.endEditing(true)
        self.loadingView.isHidden = false
        self.activityIndicator.startAnimating()
        
        vm.userSearchedPin(map: self.mapView,
                           address: address) {
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.view.endEditing(true)
                self.rightView.isHidden = false
                self.leftView.isHidden = false
                self.searchLocationTF.text?.removeAll()
            }
        } onError: { title, body in
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.view.endEditing(true)
            }
            AlertView.shared.addAlert(vc: self, title: title, body: body)
        }
        return true
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
    
    // MARK: - Remove Keyboard on Drag
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if vm.keyboardIsShown {
            view.endEditing(true)
            vm.keyboardIsShown = false
        }
    }
    
    // MARK: - Render Direction Polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.systemBlue
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
        topView.addSubview(transportTypeButton)
        topView.addSubview(searchLocationTF)
        topView.addSubview(showSavedLocationsButton)
        // Activity Indicator
        mapView.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(searchingText)
        // Right View
        mapView.addSubview(rightView)
        rightView.addSubview(buttonsStack)
        buttonsStack.addArrangedSubview(removeLocationButton)
        buttonsStack.addArrangedSubview(saveLocationButton)
        buttonsStack.addArrangedSubview(showDirectionsButton)
        // Left View
        mapView.addSubview(leftView)
        leftView.addSubview(googleMapsButton)
        
        setTopView()
        setActivityIndicator()
        setRightView()
        setLeftView()
    }
    
    // MARK: - Set Top View
    private func setTopView() {
        topView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 60).isActive = true
        topView.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 12).isActive = true
        topView.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -12).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        topView.layer.cornerRadius = 10

        transportTypeButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        transportTypeButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        transportTypeButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        transportTypeButton.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 12).isActive = true
        
        searchLocationTF.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        searchLocationTF.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        searchLocationTF.leftAnchor.constraint(equalTo: transportTypeButton.rightAnchor, constant: 12).isActive = true
        searchLocationTF.rightAnchor.constraint(equalTo: showSavedLocationsButton.leftAnchor, constant: -12).isActive = true
        searchLocationTF.heightAnchor.constraint(equalToConstant: 35).isActive = true
        searchLocationTF.delegate = self
        
        showSavedLocationsButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        showSavedLocationsButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        showSavedLocationsButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        showSavedLocationsButton.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -12).isActive = true
    }
    
    // MARK: - Activity Indicator
    private func setActivityIndicator() {
        loadingView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        activityIndicator.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 10).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        
        searchingText.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10).isActive = true
        searchingText.rightAnchor.constraint(equalTo: loadingView.rightAnchor).isActive = true
        searchingText.leftAnchor.constraint(equalTo: loadingView.leftAnchor).isActive = true
        
    }
    
    // MARK: - Right Side View
    private func setRightView() {
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
    
    private func setLeftView() {
        leftView.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20).isActive = true
        leftView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -40).isActive = true
        leftView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        leftView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        leftView.layer.cornerRadius = 10
        
        googleMapsButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        googleMapsButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        googleMapsButton.centerXAnchor.constraint(equalTo: leftView.centerXAnchor).isActive = true
        googleMapsButton.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
    }
}
