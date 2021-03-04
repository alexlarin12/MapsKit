//
//  RecoveryPasswordViewController.swift
//  MapsKit
//
//  Created by Alex Larin on 01.03.2021.
//

import UIKit

final class RecoveryPasswordViewController: UIViewController {
    
    //MARK: - Constants and Variables
    let userRepository = UserRepository()
    
    @IBOutlet weak var login: UITextField!
    
    @IBAction func recovery(_ sender: Any) {
        guard
            let login = login.text,
            let user = try? userRepository.searchUser(login: login),
            !user.isEmpty
        else {
            return
        }
        // Сообщение с паролем пользователю.
        let alert = UIAlertController(title: "Ваш пароль: \(user[0].password)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
