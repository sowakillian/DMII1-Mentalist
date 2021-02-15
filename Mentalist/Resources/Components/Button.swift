//
//  Button.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation
import UIKit

class Button: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    func setupButton() {
        setTitleColor(UIColor.MainTheme.white, for: .normal)
        backgroundColor      = UIColor.MainTheme.mainPurple
        layer.cornerRadius   = self.frame.height/2
        layer.borderWidth    = 0
    }
    
    func setDisabled() {
        alpha = 0.3
    }
    
    func setEnabled() {
        alpha = 1
    }

}

