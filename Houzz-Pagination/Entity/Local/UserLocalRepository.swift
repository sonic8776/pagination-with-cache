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
    case loadError
    case deleteError
}

enum UserLocalRepositoryError: Error {
    case encodeError
    case saveError
    case loadImageError
    case deleteError
}

protocol UserLocalRepositoryProtocol {
    func loadUser(withID id: String, completion: @escaping (UserLocalRepositoryResult) -> Void)
    func saveUser(fromRemote user: UserRemoteDTO, completion: ((Result<Void, UserLocalRepositoryError>) -> Void)?)
    func loadUserImage(wtihID id: String, completion: @escaping (Result<Data, UserLocalRepositoryError>) -> Void)
    func saveUserImage(withID id: String, imageData data: Data, completion: ((Result<Void, UserLocalRepositoryError>) -> Void)?)
    func deleteUserImage(withID id: String, completion: @escaping (Result<Void, UserLocalRepositoryError>) -> Void)
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
    
    func saveUser(fromRemote user: UserRemoteDTO, completion: ((Result<Void, UserLocalRepositoryError>) -> Void)?) {
        let id = user.id
        guard let json = JSONEncoder().toJson(from: user) else {
            completion?(.failure(.encodeError))
            return
        }
        store.insert(withID: id, json: json)
        store.saveToStore { result in
            switch result {
            case .success(()):
                print("Did save users to store!")
                completion?(.success(()))
            case .failure(_):
                completion?(.failure(.saveError))
            }
        }
    }
    
    // MARK: - Image
    
    func loadUserImage(wtihID id: String, completion: @escaping (Result<Data, UserLocalRepositoryError>) -> Void) {
        imageStore.retrieve(withID: id) { result in
            switch result {
            case .found(let imageData):
                if let data = imageData as? Data {
                    completion(.success(data))
                } else {
                    completion(.failure(.loadImageError))
                }
                
            default:
                completion(.failure(.loadImageError))
            }
        }
    }
    
    func saveUserImage(withID id: String, imageData data: Data, completion: ((Result<Void, UserLocalRepositoryError>) -> Void)?) {
        imageStore.insert(withID: id, imageData: data)
        imageStore.saveToStore { result in
            switch result {
            case .success():
                completion?(.success(()))
            case .failure(_):
                completion?(.failure(.saveError))
            }
        }
    }
    
    // expiry
    func deleteUserImage(withID id: String, completion: @escaping (Result<Void, UserLocalRepositoryError>) -> Void) {
        imageStore.delete(withID: id)
        imageStore.saveToStore { result in
            switch result {
            case .success():
                completion(.success(()))
            case .failure(_):
                completion(.failure(.deleteError))
            }
        }
    }
}
