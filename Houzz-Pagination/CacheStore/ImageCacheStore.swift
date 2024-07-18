//
//  ImageCacheStore.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/16.
//

import Foundation

class ImageCacheStore: ImageCacheStoreProtocol {
    
    private var cacheDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    typealias Cache = [String: Any]
    private var cache: Cache = [:] // ["id": image file url]
    
    /// imageURLs.json 的 URL
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
        
        loadFromStore { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let cache):
                self.cache = cache
            default:
                // 第一次運行一定會找不到，因為 cache folder 還沒有這個 file
                break
            }
        }
    }
    
    // Load image URLs from store (imageURLs.json file)
    func loadFromStore(completion: @escaping (Result<[String : Any], CacheStoreError>) -> Void) {
        do {
            // 讀取 Cache folder url 內容並轉成 Data
            let data = try Data(contentsOf: storeURL)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            // 把 data 轉成 Cache
            if let cache = jsonObject as? Cache {
                // self.cache = cache -> 不要寫在這裡，由呼叫的地方決定如何使用傳出去的 cache
                completion(.success(cache))
            } else {
                completion(.failure(.failureLoadCache))
            }
            
        } catch {
            print("Error loadFromStore: \(error)")
            completion(.failure(.failureLoadCache))
        }
    }
    
    // Save image URLs to store (JSON file)
    func saveToStore(completion: @escaping (Result<Void, CacheStoreError>) -> Void) {
        do {
            // 把 Cache 轉成 Data
            let data = try JSONSerialization.data(withJSONObject: cache, options: [.prettyPrinted])
            try data.write(to: storeURL, options: [])
            completion(.success(()))
            
        } catch {
            print("Error saveToStore: \(error)")
            completion(.failure(.failureSaveCache))
        }
    }
    
    // ImageCacheStore 不會碰觸到 UIKit，而是讓外層去把 UIImage 轉為 Data 傳進來
    func insert(withID id: String, imageData: Data) {
        do {
            // 1. save image to file and get file url
            let fileURL = cacheDirectory.appendingPathComponent("\(id).jpg")
            try imageData.write(to: fileURL)
            
            // 2. cache[id] = file name
            cache[id] = "\(id).jpg"
            
        } catch {
            print("Error insert image file: \(error)")
        }
    }
    
    // Get image file and convert to data
    func retrieve(withID id: String, completion: @escaping (RetrieveStoreResult) -> Void) {
        guard let imageFileName = cache[id] as? String else {
            completion(.empty)
            return
        }
        
        let imageFileURL = cacheDirectory.appendingPathComponent(imageFileName)
        
        do {
            // parse image file url to image data and pass
            let data = try Data(contentsOf: imageFileURL)
            completion(.found(data))
        } catch {
            print("Error converting imageFileURL to data: \(error), imageFileURL: \(imageFileURL)")
            completion(.parsingError)
        }
    }
    
    // Delete image file
    func delete(withID id: String) {
        guard let imageFileName = cache[id] as? String else {
            return
        }
        
        let imageFileURL = cacheDirectory.appendingPathComponent(imageFileName)
        
        do {
            try FileManager.default.removeItem(at: imageFileURL)
            cache.removeValue(forKey: id)
        } catch {
            print("Error delete image file: \(error)")
        }
    }
}
