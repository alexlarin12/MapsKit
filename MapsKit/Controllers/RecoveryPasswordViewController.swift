//
//  RecoveryPasswordViewController.swift
//  MapsKit
//
//  Created by Alex Larin on 01.03.2021.
//

import UIKit

final class RecoveryPasswordViewController: UIViewController {
    
    @IBOutlet weak var loginView: UITextField!
    
    @IBAction func recovery(_ sender: Any) {
        guard
            let login = loginView.text,
            login == LoginViewController.Constants.login else {
            
                return
        }
        
        showPassword()
    }
    
    private func showPassword() {
        let alert = UIAlertController(title: "Пароль", message: "123456", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
