//
//  Launch.swift
//  MapsKit
//
//  Created by Alex Larin on 01.03.2021.
//

import UIKit

class Launch: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey: "isLogin") {
                   performSegue(withIdentifier: "toMain", sender: self)
               } else {
                   performSegue(withIdentifier: "toMain", sender: self)
               }
    }

}
