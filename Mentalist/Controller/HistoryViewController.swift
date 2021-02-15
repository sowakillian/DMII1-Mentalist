//
//  HistoryViewController.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation
import UIKit

class HistoryViewController:UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var historyList:[String] = ["zz", "zz", "zz"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        observeHistoryModification()
    }
    
    func observeHistoryModification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldReload), name: NSNotification.Name(rawValue: "historyEdited"), object: nil)
    }
    
    @objc func shouldReload() {
        self.tableView.reloadData()
    }
    
}

extension HistoryViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension HistoryViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BLEManager.instance.history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyItemCell")! as UITableViewCell
        
        if BLEManager.instance.history[indexPath.row].received == true {
            cell.textLabel?.text = "Reçu : \(BLEManager.instance.history[indexPath.row].message)"
        } else {
            cell.textLabel?.text = "Envoyé : \(BLEManager.instance.history[indexPath.row].message)"
        }
        return cell
    }
    
}
