//
//  ViewController.swift
//  MyDocuments
//
//  Created by Ислам on 09.12.2024.
//

import UIKit

class DocumentsViewController: UITableViewController {
    private var currentDirectory: URL = FileService.shared.documentsDirectory
    private var files: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFiles()
        NotificationCenter.default.addObserver(self, selector: #selector(loadFiles), name: .sortOrderChanged, object: nil)
    }
    
    private func setupUI() {
        title = currentDirectory.lastPathComponent
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotoTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Папка", style: .plain, target: self, action: #selector(addFolderTapped))
    }
    
    @objc private func loadFiles() {
        files = FileService.shared.listFiles(in: currentDirectory)
        if UserDefaults.standard.bool(forKey: "sortOrderAscending") {
            files.sort { $0.lastPathComponent < $1.lastPathComponent }
        } else {
            files.sort { $0.lastPathComponent > $1.lastPathComponent }
        }
        tableView.reloadData()
    }
    
    @objc private func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    private func promptForFileName(image: UIImage) {
        let alertController = UIAlertController(title: "Введите имя файла", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Имя файла"
        }
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let fileName = alertController.textFields?.first?.text, !fileName.isEmpty else {
                self.saveImage(image, withName: UUID().uuidString + ".jpg")
                return
            }
            self.saveImage(image, withName: fileName + ".jpg")
        }
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func saveImage(_ image: UIImage, withName fileName: String) {
        if let _ = FileService.shared.saveImage(image, named: fileName, in: currentDirectory) {
            loadFiles()
        }
    }
    
    @objc private func addFolderTapped() {
        let alertController = UIAlertController(title: "Создать папку", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Имя папки"
        }
        let createAction = UIAlertAction(title: "Создать", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let folderName = alertController.textFields?.first?.text, !folderName.isEmpty else { return }
            let folderURL = self.currentDirectory.appendingPathComponent(folderName)
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
                self.loadFiles()
            } catch {
                print("Ошибка создания папки: \(error)")
            }
        }
        alertController.addAction(createAction)
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func navigateToFolder(at folderURL: URL) {
        let viewController = DocumentsViewController()
        viewController.currentDirectory = folderURL
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let fileURL = files[indexPath.row]
        cell.textLabel?.text = fileURL.lastPathComponent
        cell.detailTextLabel?.text = FileService.shared.getFileMetadata(for: fileURL)
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
        cell.accessoryType = isDirectory.boolValue ? .disclosureIndicator : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileURL = files[indexPath.row]
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
            navigateToFolder(at: fileURL)
        } else if let image = UIImage(contentsOfFile: fileURL.path) {
            let detailsVC = DetailsViewController()
            detailsVC.image = image
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fileURL = files[indexPath.row]
            FileService.shared.deleteFile(at: fileURL)
            loadFiles()
        }
    }
}

extension DocumentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            promptForFileName(image: image)
        }
    }
}
