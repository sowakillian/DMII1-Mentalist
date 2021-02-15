//
//  CommunicationViewController.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation
import UIKit
import StringMetric

class CommunicationViewController:UIViewController {
    @IBOutlet weak var writeTextField: UITextField!
    @IBOutlet weak var readCollectionView: UICollectionView!
    var readingState: Int = 0
    var moodStrings: [String:String] = ["content": "", "pas content": "", "pourquoi j'ai choisi DMII?": ""]
    
    var splittedString: [String] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        readCollectionView.delegate = self
        readCollectionView.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func writeClicked(_ sender: Any) {
        print("write clicked")
        if let data = writeTextField.text?.data(using: .utf8) {
            BLEManager.instance.sendData(data: data) { success in
                print("data successfully written")
                BLEManager.instance.history.append(HistoryItem(message: String(decoding: data, as: UTF8.self), received: false))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "historyEdited"), object: nil)
            }
        }
    }
    
    func editHistory(message: String, received: Bool) {
        BLEManager.instance.history.append(HistoryItem(message: message, received: received))
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "historyEdited"), object: nil)
    }
    
    @IBAction func readClicked(_ sender: Any) {
        print("read clicked")
        self.splittedString = []
        
        BLEManager.instance.readData() { (message) in
            
            if let message = message {
                self.splittedString = message.components(separatedBy: ":")
                
                if self.readingState == 1 {
                    self.splittedString.reverse()
                }
                
                self.editHistory(message: message, received: true)
                print(self.splittedString)
                
                if self.readingState == 0 || self.readingState == 1 {
                    self.splittedString.forEach { (stringItem) in
                        self.editHistory(message: stringItem, received: false)
                        if let characterAsData = stringItem.data(using: .utf8) {
                            BLEManager.instance.sendData(data: characterAsData) { success in
                            
                            }
                        }
                    }
                    self.readCollectionView.reloadData()
                }
                
                if self.readingState == 2 {
                    print("i get datas")
                    self.moodStrings["content"] = self.splittedString[0]
                    self.moodStrings["pas content"] = self.splittedString[1]
                    self.moodStrings["pourquoi j'ai choisi DMII?"] = self.splittedString[2]
                    print(self.moodStrings)
                }
                
                if self.readingState == 3 {
                    print("message", message)
                    
                    if let happy = self.moodStrings["content"], let sadValue = self.moodStrings["pas content"], let whyValue = self.moodStrings["pourquoi j'ai choisi DMII?"] {
                        let distanceHappy = message.distance(between: happy)
                        let distanceSad = message.distance(between: sadValue)
                        let distanceWhy = message.distance(between: whyValue)
                        
                        let smallest = min(distanceHappy, distanceSad, distanceWhy)
                        
                        print(smallest, "smallest")
                        print(distanceHappy, distanceSad, distanceWhy)
    
                        if smallest == distanceHappy {
                            BLEManager.instance.sendData(data: "content".data(using: .utf8)!) { success in
                                self.editHistory(message: "content", received: false)
                            }
                        }
                        
                        if smallest == distanceSad {
                            BLEManager.instance.sendData(data: "pas content".data(using: .utf8)!) { success in
                                self.editHistory(message: "pas content", received: false)
                            }
                        }
                        
                        if smallest == distanceWhy {
                            BLEManager.instance.sendData(data: "pourquoi j'ai choisi DMII?".data(using: .utf8)!) { success in
                                self.editHistory(message: "pourquoi j'ai choisi DMII?", received: false)
                            }
                        }
                    }

                }

            }
            
            self.readingState += 1
        }
        
    }
    
    
    
}

extension CommunicationViewController:UICollectionViewDelegate {
    
}

extension CommunicationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 146, height: 33)
    }
}

extension CommunicationViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        splittedString.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = readCollectionView.dequeueReusableCell(withReuseIdentifier: "ReadCollectionViewCell", for: indexPath) as! ReadCollectionViewCell
        cell.characterLabel.text = splittedString[indexPath.row]
        cell.contentView.layer.cornerRadius = 5
        return cell
    }
    
    
}
