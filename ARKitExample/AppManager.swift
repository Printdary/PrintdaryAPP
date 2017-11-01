//
//  AppManager.swift
//  ARKitExample
//
//  Created by Wang on 10/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

enum UserRole {
    case A
    case B
}

final class AppManager {
    
    static let shared = AppManager()
    var role: UserRole
    
    init() {
        self.role = .A
    }
    
    func isSelected_A() -> Bool {
        return self.role == .A
    }
    
    func isSelected_B() -> Bool {
        return self.role == .B
    }
    
    func select_A() {
        self.role = .A
    }
    
    func select_B() {
        self.role = .B
    }
}
