//
//  RootSegue.swift
//  MapsKit
//
//  Created by Alex Larin on 01.03.2021.
//

import UIKit

class RootSegue: UIStoryboardSegue {
    override func perform() {
        UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.rootViewController = destination
        
    }
}
