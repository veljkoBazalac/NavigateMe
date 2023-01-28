//
//  SelectLocationVC.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 28.1.23..
//

import UIKit

protocol GoToSavedLocationDelegate {
    func didSelectSavedLocation(location: LocationEntity)
}

class SelectLocationVC: UIViewController {
    
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(SavedLocationCell.self,
                       forCellReuseIdentifier: SavedLocationCell.indentifier)
        return table
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Saved Locations"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    var delegate: GoToSavedLocationDelegate?
    
    private let coreDataManager = CoreDataManager.shared
    private let mapManager = MapManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.showsVerticalScrollIndicator = false
        
        setUIElements()
    }
}

// MARK: - UI Elements
extension SelectLocationVC {
    // MARK: - Set UI
    private func setUIElements() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        setConstrains()
    }
    
    private func setConstrains() {
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
}

// MARK: - Table View
extension SelectLocationVC: UITableViewDelegate, UITableViewDataSource, OpenGoogleMapsDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataManager.savedLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SavedLocationCell.indentifier, for: indexPath) as! SavedLocationCell
        
        let location = coreDataManager.savedLocations[indexPath.row]
    
        cell.countryFlag.text = location.isoCode
        cell.nameLabel.text = location.name
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationEntity = coreDataManager.savedLocations[indexPath.row]
        delegate?.didSelectSavedLocation(location: locationEntity)
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            coreDataManager.deleteLocation(index: indexPath.row) {
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    // MARK: - Delegate Method
    func openGoogleMaps(cell: SavedLocationCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            print("Error Getting IndexPath for Cell.")
            return
        }
        
        let locationEntity = coreDataManager.savedLocations[indexPath.row]
        
        guard
            let name = locationEntity.name,
            let iso = locationEntity.isoCode else {
            print("Error Getting Name and ISO Code.")
            return
        }
        
        let location = Location(name: name,
                                isoCode: iso,
                                latitude: locationEntity.latitude,
                                longitude: locationEntity.longitude)
        
        mapManager.openGoogleMaps(location: location)
    }
}
