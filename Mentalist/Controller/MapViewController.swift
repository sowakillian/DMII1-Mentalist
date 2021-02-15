//
//  MapViewController.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation
import UIKit

class MapViewController:UIViewController {
    
    @IBOutlet weak var historyCollectionView: UICollectionView!
    var historyList:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyCollectionView.delegate = self
        historyCollectionView.dataSource = self
        
        print(historyList.count)
    }
    
    @IBAction func readClicked(_ sender: Any) {
        
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
