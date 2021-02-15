//
//  MapViewController.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation
import UIKit
import MapKit

class MapViewController:UIViewController {
    
    @IBOutlet weak var historyCollectionView: UICollectionView!
    var historyList:[String] = []
    @IBOutlet weak var mapView: MKMapView!
    
    // - Constants
    private let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyCollectionView.delegate = self
        historyCollectionView.dataSource = self
        
        print(historyList.count)
    }
    
    private func setTownLocation(town: String) {
        self.locationManager.getLocation(forPlaceCalled: town) { location in
            guard let location = location else { return }
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = town
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(annotation)
            
        }
    }
    
    @IBAction func readClicked(_ sender: Any) {
        BLEManager.instance.readMapData() { (message) in
            if let message = message {
                BLEManager.instance.history.append(HistoryItem(message: message, received: true))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "historyEdited"), object: nil)
                
                self.setTownLocation(town: message)
                
                if !self.historyList.contains(message) {
                    self.historyList.append(message)
                    self.historyCollectionView.reloadData()
                }

            }

        }
    }
}

extension MapViewController:UICollectionViewDelegate {
    
}

extension MapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 128, height: 128)
    }
}

extension MapViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        historyList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = historyCollectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCollectionViewCell", for: indexPath) as! HistoryCollectionViewCell
        cell.cityLabel.text = historyList[indexPath.row]
        return cell
    }
    
    
}
