//
//  ScanViewController.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController {
    
    var periphReady = false
    @IBOutlet weak var writeTextField: UITextField!
    var periph:CBPeripheral?
    @IBOutlet weak var tableView: UITableView!
    var periphList:[[CBPeripheral:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    @IBAction func scanClicked(_ sender: Any) {
        startScan()
    }
    
    
    func startScan() {
        print("scan start")
        BLEManager.instance.scan { periph, name  in
            print("**")
            print(periph, name)
            if name == "jacky" {
                print("i found peripheral")
                self.periphList.append([periph:name])
                self.tableView.reloadData()
                BLEManager.instance.stopScan()
            }
        }
    }

}

extension ScanViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let periph = periphList[indexPath.row].keys.first {
            BLEManager.instance.connectPeripheral(periph) { per in
                self.periph = periph
                
                BLEManager.instance.discoverPeripheral(per) { (periphReady) in
                    self.periphReady = true
                    
                    self.performSegue(withIdentifier: "toCommunication", sender: nil)
                }
            }
        }
    }
}

extension ScanViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periphList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriphNameCell")! as UITableViewCell
        cell.textLabel?.text = periphList[indexPath.row].values.first
        return cell
    }
    
}
