//
//  UserLocalRepository.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/11.
//

import Foundation

enum UserLocalRepositoryResult {
    case empty
    case found(UserLocalDTO)
    case decodeError
    case encodeError
    case saveError
}

enum UserLocalRepositoryError: Error {
    case deleteError
}

protocol UserLocalRepositoryProtocol {
    func loadUser(withID id: String, completion: @escaping (UserLocalRepositoryResult) -> Void)
    func saveUser(fromRemote user: UserRemoteDTO, completion: ((UserLocalRepositoryResult) -> Void)?)
}

class UserLocalRepository: UserLocalRepositoryProtocol {
    
    let store: CacheStoreProtocol
    let imageStore: ImageCacheStoreProtocol
    init(store: CacheStoreProtocol, imageStore: ImageCacheStoreProtocol) {
        self.store = store
        self.imageStore = imageStore
    }
    
    // MARK: - User info json
    
    func loadUser(withID id: String, completion: @escaping (UserLocalRepositoryResult) -> Void) {
        store.retrieve(withID: id) { result in
            switch result {
            case .found(let json):
                guard let localDTO = UserLocalDTO.toDTO(fromJson: json) else {
                    completion(.empty)
                    return
                }
                completion(.found(localDTO))
            default:
                completion(.empty)
            }
        }
    }
    
    func saveUser(fromRemote user: UserRemoteDTO, completion: ((UserLocalRepositoryResult) -> Void)?) {
        let id = user.id
        guard let json = JSONEncoder().toJson(from: user) else {
            completion?(.encodeError)
            return
        }
        store.insert(withID: id, json: json)
        store.saveToStore { result in
            switch result {
            case .success(()):
                break
            case .failure(_):
                completion?(.saveError)
            }
        }
    }
    
    // MARK: - Image
    
    func loadUserImage(wtihID id: String, completion: @escaping (Data) -> Void) {
        
    }
    
    // expiry
    func deleteUserImage(withID id: String, completion: @escaping (Result<Void, UserLocalRepositoryError>) -> Void) {
        
    }
}
