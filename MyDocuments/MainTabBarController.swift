//
//  MainTabBarController.swift
//  MyDocuments
//
//  Created by Ислам on 12.12.2024.
//


import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let filesVC = UINavigationController(rootViewController: DocumentsViewController())
        filesVC.tabBarItem = UITabBarItem(title: "Файлы", image: UIImage(systemName: "folder"), tag: 0)
        
        let settingsVC = UINavigationController(rootViewController: SettingsViewController())
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gearshape"), tag: 1)
        
        viewControllers = [filesVC, settingsVC]
    }
}
