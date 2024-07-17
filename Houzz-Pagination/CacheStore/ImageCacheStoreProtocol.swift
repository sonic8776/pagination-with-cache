//
//  ImageCacheStoreProtocol.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/17.
//

import Foundation

protocol ImageCacheStoreProtocol {
    func loadFromStore(completion: @escaping (Result<[String: Any], CacheStoreError>) -> Void)
    func saveToStore(completion: @escaping (Result<Void, CacheStoreError>) -> Void)
    
    func insert(withID id: String, imageData: Data)
    func retrieve(withID id: String, completion: @escaping (RetrieveStoreResult) -> Void)
    func delete(withID id: String)
}
