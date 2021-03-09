//
//  RegistrationViewController.swift
//  MapsKit
//
//  Created by Alex Larin on 01.03.2021.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    let userRepository = UserRepository()
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldState()
        addObservers()
    }
    
    @IBAction func createNewAccaunt(_ sender: Any) {
        let login = loginTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let error = checkTextFields()
        let repeatLogin = try? userRepository.searchUser(login: login)
        if error == nil && ((repeatLogin?.isEmpty) == true) {
            userRepository.saveUserData(login: login, password: password)
            performSegue(withIdentifier: "toMain", sender: sender)
        }else{
            let alert = UIAlertController(title: "Error", message: "Аккаунт с таким именем уже существует", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { _ in
            }
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    // метод проверки заполнения текстовых полей:
    func checkTextFields() -> String? {
        if loginTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Заполните все поля."
        }else{
            return nil
        }
    }
    // состояние полей textField - скрытие текста, автокоррекция:
    func textFieldState() {
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
        loginTextField.autocorrectionType = .no
    }
    // Подписка на уведомления (приложение не активно - активно)
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(hideTextFields), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(showTextFields), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    // скрыть логин и пароль
    @objc func hideTextFields() {
        self.passwordTextField.text = "SECURITY"
        self.loginTextField.text = "SECURITY"
        self.passwordTextField.isSecureTextEntry = false
        
    }
    // повтор регистрации
    @objc func showTextFields() {
        let alert = UIAlertController(title: "Error", message: "Повторите ввод", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
        }
        alert.addAction(action)
        present(alert, animated: true)
        self.passwordTextField.text = ""
        self.loginTextField.text = ""
        self.passwordTextField.isSecureTextEntry = true
    }
}
