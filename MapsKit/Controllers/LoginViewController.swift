//
//  LoginViewController.swift
//  MapsKit
//
//  Created by Alex Larin on 01.03.2021.
//

import UIKit


import UIKit

final class LoginViewController: UIViewController {
    
    enum Constants {
        static let login = "admin"
        static let password = "123456"
    }
    
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          
  // Показав контроллер авторизации, проверяем: если мы авторизованы,
  // сразу переходим к основному сценарию
          if UserDefaults.standard.bool(forKey: "toLogin") {
              performSegue(withIdentifier: "toMain", sender: self)
          }
          
      }

    @IBAction func login(_ sender: Any) {
        guard
            let login = loginView.text,
            let password = passwordView.text,
            login == Constants.login && password == Constants.password
        else {
            return
        }
        // Сохраним флаг, показывающий, что мы авторизованы
                UserDefaults.standard.set(true, forKey: "toLogin")
        // Перейдём к главному сценарию
                performSegue(withIdentifier: "toMain", sender: sender)

    }

    @IBAction func recovery(_ sender: Any) {
        performSegue(withIdentifier: "onRecover", sender: sender)
        
    }
    
// Unwind segue для выхода автоматически удаляет флаг авторизации
    @IBAction func logout(_ segue: UIStoryboardSegue) {
        UserDefaults.standard.set(false, forKey: "toLogin")
    }
}

