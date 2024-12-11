//
//  FileService.swift
//  MyDocuments
//
//  Created by Ислам on 11.12.2024.
//


import UIKit

class FileService {
    static let shared = FileService()
    private let fileManager = FileManager.default
    
    var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func listFiles(in directory: URL? = nil) -> [URL] {
        let targetDirectory = directory ?? documentsDirectory
        do {
            return try fileManager.contentsOfDirectory(at: targetDirectory, includingPropertiesForKeys: nil, options: [])
        } catch {
            print("Error listing files: \(error)")
            return []
        }
    }
    
    func saveImage(_ image: UIImage, named fileName: String, in directory: URL? = nil) -> URL? {
        let targetDirectory = directory ?? documentsDirectory
        let fileURL = targetDirectory.appendingPathComponent(fileName)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func deleteFile(at fileURL: URL) {
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("Error deleting file: \(error)")
        }
    }
    
    func getFileMetadata(for fileURL: URL) -> String {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? Int64,
               let modificationDate = attributes[.modificationDate] as? Date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                let sizeInKB = Double(fileSize) / 1024.0
                return "Size: \(String(format: "%.2f", sizeInKB)) KB, Modified: \(dateFormatter.string(from: modificationDate))"
            }
        } catch {
            print("Error fetching file attributes: \(error)")
        }
        return "No metadata available"
    }
}
