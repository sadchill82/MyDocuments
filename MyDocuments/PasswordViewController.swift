//
//  PasswordViewController.swift
//  MyDocuments
//
//  Created by Ислам on 12.12.2024.
//


import UIKit
import KeychainAccess

class PasswordViewController: UIViewController {
    private let keychain = Keychain(service: "com.example.FileManager")
    private var state: PasswordState = .createPassword
    private var enteredPassword: String?
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите пароль"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать пароль", for: .normal)
        button.addTarget(PasswordViewController.self, action: #selector(handleAction), for: .touchUpInside)
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        checkPasswordState()
    }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [passwordField, actionButton, errorLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func checkPasswordState() {
        if let _ = keychain["password"] {
            state = .enterPassword
            actionButton.setTitle("Введите пароль", for: .normal)
        } else {
            state = .createPassword
        }
    }
    
    @objc private func handleAction() {
        guard let text = passwordField.text, text.count >= 4 else {
            showError("Пароль должен содержать минимум 4 символа.")
            return
        }
        errorLabel.isHidden = true
        
        switch state {
        case .createPassword:
            enteredPassword = text
            state = .repeatPassword
            actionButton.setTitle("Повторите пароль", for: .normal)
            passwordField.text = ""
            
        case .repeatPassword:
            if text == enteredPassword {
                keychain["password"] = text
                transitionToMainScreen()
            } else {
                showError("Пароли не совпадают. Попробуйте ещё раз.")
                resetToCreateState()
            }
            
        case .enterPassword:
            if let savedPassword = keychain["password"], savedPassword == text {
                transitionToMainScreen()
            } else {
                showError("Неверный пароль.")
            }
        }
    }
    
    private func resetToCreateState() {
        state = .createPassword
        actionButton.setTitle("Создать пароль", for: .normal)
        passwordField.text = ""
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func transitionToMainScreen() {
        let tabBar = MainTabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }
}

enum PasswordState {
    case createPassword
    case repeatPassword
    case enterPassword
}
