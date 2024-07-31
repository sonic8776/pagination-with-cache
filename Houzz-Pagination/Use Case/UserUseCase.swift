//
//  UserUseCase.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import UIKit

enum UserUseCaseError: Error {
    case useCaseError
    case parsingError
}

protocol UserUseCaseProtocol {
    func loadUser(fromPage page: Int, completion: @escaping ((Result<[User], UserUseCaseError>) -> Void))
}

class UserUseCase: UserUseCaseProtocol {
    let dispatchGroup = DispatchGroup()
    
    
    let remoteRepo: UserRemoteRepositoryProtocol
    let localRepo: UserLocalRepositoryProtocol
    
    init(remoteRepo: UserRemoteRepositoryProtocol, localRepo: UserLocalRepositoryProtocol) {
        self.remoteRepo = remoteRepo
        self.localRepo = localRepo
    }
    
    func makeIDs(fromPage page: Int) -> [String] {
        // 1 -> 1 ~ 10
        // 2 -> 11 ~ 20
        // ((page - 1) * 10 + 1) ~ (page * 10)
        let startIndex = (page - 1) * 10 + 1
        let endIndex = page * 10
        return (startIndex...endIndex).map { "\($0)"}
    }
    
    func loadUser(fromPage page: Int, completion: @escaping ((Result<[User], UserUseCaseError>) -> Void)) {
        let ids = makeIDs(fromPage: page)
        var users = [User]()
        
        ids.forEach { id in
            dispatchGroup.enter()
            localRepo.loadUser(withID: id) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case let .found(localDTO):
                    var user = User(fromLocalDTO: localDTO)
                    
                    self.localRepo.loadUserImage(wtihID: id) { result in
                        defer { self.dispatchGroup.leave() }
                        
                        switch result {
                        case .success(let imageData):
                            user.imageData = imageData
                        default:
                            print("Failed to load image with id \(id)")
                            return
                        }
                        users.append(user)
                    }
                    
                default:
                    self.dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // 從 localRepo 已經讀取完 user 資料，檢查若 users 數量和 ids 一致，則視為讀取 cache 成功，回傳 users 並 return
            if users.count == ids.count {
                // "aaa", "1" -> "aaa", "1"
                // "2", "1" -> "1", "2"
                let sortedUsers = users.sorted { leftUser, rightUser in
                    guard
                        let leftUserId = Int(leftUser.id),
                        let rightUserId = Int(rightUser.id)
                    else {
                        return true
                    }
                    return leftUserId < rightUserId
                }
                completion(.success(sortedUsers))
                return
            }
            
            // 只要數目對不起來，就直接讓 remoteRepo 重新 request 整頁的 users
            self.remoteRepo.requestUser(fromPage: page) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case let .success(userDTOs):
                    // save to store
                    for userDTO in userDTOs {
                        self.dispatchGroup.enter()
                        self.localRepo.saveUser(fromRemote: userDTO) { _ in
                            
                            var user = User(fromRemoteDTO: userDTO)
                            self.remoteRepo.downloadImage(fromURL: userDTO.avatar) { downloadResult in
                                defer { self.dispatchGroup.leave() }
                                switch downloadResult {
                                case .success(let data):
                                    user.imageData = data
                                    self.localRepo.saveUserImage(withID: userDTO.id, imageData: data, completion: nil)
                                    
                                case .failure(let error):
                                    print("Failed to download image from \(userDTO.avatar): \(error)")
                                }
                                users.append(user)
                            }
                        }
                    }
                    
                    self.dispatchGroup.notify(queue: .main) {
                        completion(.success(users))
                    }
                    
                case let .failure(repoError):
                    switch repoError {
                    case .failedToParseData, .failedToParseURL:
                        completion(.failure(.parsingError))
                    case .networkError:
                        completion(.failure(.useCaseError))
                    }
                }
            }
        }
    }
}
