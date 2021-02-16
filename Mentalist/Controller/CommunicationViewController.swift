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
    let communicationManager = CommunicationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readCollectionView.delegate = self
        readCollectionView.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func editHistory(message: String, received: Bool) {
        HistoryManager.instance.history.append(HistoryItem(message: message, received: received))
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "historyEdited"), object: nil)
    }
    
    @IBAction func writeClicked(_ sender: Any) {
        if let data = writeTextField.text?.data(using: .utf8) {
            BLEManager.instance.sendData(data: data) { success in
                self.editHistory(message: String(decoding: data, as: UTF8.self), received: false)
            }
        }
    }
    
    @IBAction func readClicked(_ sender: Any) {
        communicationManager.splittedString = []
        
        BLEManager.instance.readData() { (message) in
            
            if let message = message {
                self.communicationManager.splittedString = message.components(separatedBy: ":")
                
                switch self.communicationManager.readingState {
                case 0:
                    self.editHistory(message: message, received: true)
                    
                    self.communicationManager.sendSplittedStringCharacters { (success) in
                        self.readCollectionView.reloadData()
                    }
                case 1:
                    self.editHistory(message: message, received: true)
                    self.communicationManager.splittedString.reverse()
                    
                    self.communicationManager.sendSplittedStringCharacters { (success) in
                        self.readCollectionView.reloadData()
                    }
                case 2:
                    self.editHistory(message: message, received: true)
                    
                    self.communicationManager.attributeValuesToMoodStrings()
                case 3:
                    self.editHistory(message: message, received: true)
                    
                    self.communicationManager.compareAndReturnMoodString(messageReceived: message) { messageToSend in
                        self.editHistory(message: messageToSend, received: false)
                    }
                default:
                    print("unused readingState")
                }
                
                self.communicationManager.readingState += 1
                
            }
            
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
        self.communicationManager.splittedString.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = readCollectionView.dequeueReusableCell(withReuseIdentifier: "ReadCollectionViewCell", for: indexPath) as! ReadCollectionViewCell
        cell.characterLabel.text = self.communicationManager.splittedString[indexPath.row]
        cell.contentView.layer.cornerRadius = 5
        return cell
    }
    
    
}
