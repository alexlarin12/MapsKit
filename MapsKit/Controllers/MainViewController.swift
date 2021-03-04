//
//  MainViewController.swift
//  MapsKit
//
//  Created by Alex Larin on 01.03.2021.
//

import UIKit

final class MainViewController: UIViewController {
    
    @IBAction func showMap(_ sender: Any) {
        performSegue(withIdentifier: "toMap", sender: nil)
        
    }
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLogin")
        performSegue(withIdentifier: "toLaunch", sender: nil)
        
    }

}
