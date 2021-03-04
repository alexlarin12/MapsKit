//
//  Launch.swift
//  MapsKit
//
//  Created by Alex Larin on 01.03.2021.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if UserDefaults.standard.bool(forKey: "isLogin") {
            performSegue(withIdentifier: "toMain", sender: self)
        } else {
            performSegue(withIdentifier: "toAuth", sender: self)
        }
    }
    
}
