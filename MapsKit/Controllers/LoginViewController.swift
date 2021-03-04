//
//  LoginViewController.swift
//  MapsKit
//
//  Created by Alex Larin on 01.03.2021.
//

import UIKit

final class LoginViewController: UIViewController {
    
    let userRepository = UserRepository()
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldState()
        addObservers()
        print("github")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Показав контроллер авторизации, проверяем: если мы авторизованы, сразу переходим к основному сценарию
        if UserDefaults.standard.bool(forKey: "isLogin"){
            performSegue(withIdentifier: "toMain", sender: self)
        }
    }
    
    @IBAction func login(_ sender: Any) {
        guard
            let login = loginTextField.text,
            let password = passwordTextField.text,
            let user = try? userRepository.compareUserData(login: login, password: password),
            !user.isEmpty
        else {
            return
        }
        // Сохраним флаг, показывающий, что мы авторизованы
        UserDefaults.standard.set(true, forKey: "isLogin")
        // Перейдём к главному сценарию
        performSegue(withIdentifier: "toMain", sender: sender)
        
    }
    
    @IBAction func recovery(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLogin")
        performSegue(withIdentifier: "onRecover", sender: sender)
        
    }
    @IBAction func registration(_ sender: Any) {
        performSegue(withIdentifier: "toRegistration", sender: sender)
        
    }
    
    // Unwind segue для выхода автоматически удаляет флаг авторизации
    @IBAction func logout(_ segue: UIStoryboardSegue) {
        UserDefaults.standard.set(false, forKey: "isLogin")
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
            self.passwordTextField.text = ""
            self.loginTextField.text = ""
            self.passwordTextField.isSecureTextEntry = true
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
}

