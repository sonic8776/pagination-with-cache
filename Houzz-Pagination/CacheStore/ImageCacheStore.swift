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
    private var cache: Cache = [:]
    
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
    
    func loadFromStore(completion: @escaping (Result<[String : Any], CacheStoreError>) -> Void) {
    }
    
    func saveToStore(completion: @escaping (Result<Void, CacheStoreError>) -> Void) {
    }
    func insert(withID id: String, imageData: Data) {
    }
    
    func retrieve(withID id: String, completion: @escaping (RetrieveStoreResult) -> Void) {
    }
    
    func delete(withID id: String) {
    }
}
