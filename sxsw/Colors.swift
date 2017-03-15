//
//  Colors.swift
//  sxsw
//
//  Created by Alex on 3/14/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import Foundation
import UIKit

class Colors {
    var gl:CAGradientLayer!
    
    init() {
        let colorTop = UIColor(red: 192.0 / 255.0, green: 38.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 231 / 255.0, green: 86 / 255.0, blue: 99 / 255.0, alpha: 1.0).cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}
