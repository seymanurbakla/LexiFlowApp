import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let fileManager = FileManager.default
    private let appSupportDirectory: URL
    
    private init() {
        // 1. Files to be stored in Application Support directory
        // Using a predefined folder name to group all app files safely
        if let baseFolder = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            // Note: avoiding Bundle.main as requested by appending a hardcoded folder name
            appSupportDirectory = baseFolder.appendingPathComponent("AppStorage", isDirectory: true)
        } else {
            // Fallback
            appSupportDirectory = fileManager.temporaryDirectory.appendingPathComponent("AppStorage")
        }
        
        setupDirectory()
    }
    
    // 2. Automatic folder creation if it doesn't exist
    private func setupDirectory() {
        if !fileManager.fileExists(atPath: appSupportDirectory.path) {
            do {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create Application Support directory: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Safe read/write functions
    
    /// Saves generic encodable objects safely to the disk.
    func save<T: Encodable>(_ object: T, to filename: String) {
        // Ensure directory continues to exist just in case it was deleted
        setupDirectory()
        
        let fileURL = appSupportDirectory.appendingPathComponent(filename)
        
        do {
            let data = try JSONEncoder().encode(object)
            // Writing atomically ensures file integrity if writing is interrupted.
            // .completeFileProtection provides encryption at rest, keeping data secure.
            try data.write(to: fileURL, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("StorageManager: Failed to save file \(filename): \(error.localizedDescription)")
        }
    }
    
    /// Loads decoded models from the disk securely.
    func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        let fileURL = appSupportDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let result = try JSONDecoder().decode(type, from: data)
            return result
        } catch {
            print("StorageManager: Failed to load file \(filename): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Deletes a file.
    func delete(filename: String) {
        let fileURL = appSupportDirectory.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("StorageManager: Failed to delete file \(filename): \(error.localizedDescription)")
        }
    }
}
