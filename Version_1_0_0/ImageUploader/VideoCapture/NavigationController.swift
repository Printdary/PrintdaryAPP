//
//  NavigationController.swift
//  VideoCapture
//
//  Created by Armen Nikodhosyan on 11.12.17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit


class NavigationController: UINavigationController {
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
