//
//  SettingsViewController.swift
//  MyDocuments
//
//  Created by Ислам on 12.12.2024.
//


import UIKit

class SettingsViewController: UITableViewController {
    private let defaults = UserDefaults.standard
    private enum Setting: Int {
        case sortOrder, changePassword
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch Setting(rawValue: indexPath.row) {
        case .sortOrder:
            cell.textLabel?.text = "Сортировка файлов"
            let toggle = UISwitch()
            toggle.isOn = defaults.bool(forKey: "sortOrderAscending")
            toggle.addTarget(self, action: #selector(toggleSortOrder(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            
        case .changePassword:
            cell.textLabel?.text = "Изменить пароль"
            cell.accessoryType = .disclosureIndicator
            
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Setting(rawValue: indexPath.row) {
        case .changePassword:
            let passwordVC = PasswordViewController()
            passwordVC.modalPresentationStyle = .fullScreen
            present(passwordVC, animated: true)
            
        default:
            break
        }
    }
    
    @objc private func toggleSortOrder(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "sortOrderAscending")
        NotificationCenter.default.post(name: .sortOrderChanged, object: nil)
    }
}

extension Notification.Name {
    static let sortOrderChanged = Notification.Name("sortOrderChanged")
}
