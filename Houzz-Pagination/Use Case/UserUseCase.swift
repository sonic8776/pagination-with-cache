//
//  UserUseCase.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import Foundation

struct User {
    
    let lastName: String
    
    init(fromDTO dto: UserRemoteDTO) {
        self.lastName = dto.lastName
    }
    
    init(fromLocalDTO dto: UserLocalDTO) {
        self.lastName = dto.lastName
    }
}

enum UserUseCaseError: Error {
    case useCaseError
    case parsingError
}

protocol UserUseCaseProtocol {
    func loadUser(fromPage page: Int, completionForViewModel: @escaping ((Result<[User], UserUseCaseError>) -> Void))
}

class UserUseCase: UserUseCaseProtocol {
    
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
        return (startIndex...endIndex).map { "\($0) "}
    }
    
    func loadUser(fromPage page: Int, completionForViewModel: @escaping ((Result<[User], UserUseCaseError>) -> Void)) {
        let ids = makeIDs(fromPage: page)
        var users = [User]()
        ids.forEach {
            localRepo.loadUser(withID: $0) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case let .found(localDTO):
                    let user = User(fromLocalDTO: localDTO)
                    users.append(user)
                    
                case .empty:
                    self.remoteRepo.requestUser(fromPage: page) { result in
                        switch result {
                        case let .success(userDTOs):
                            // save to store
                            for userDTO in userDTOs {
                                self.localRepo.saveUser(fromRemote: userDTO)
                            }
                            let users: [User] = userDTOs.map { .init(fromDTO: $0) }
                            completionForViewModel(.success(users))
                        case let .failure(repoError):
                            switch repoError {
                            case .failedToParseData:
                                completionForViewModel(.failure(.parsingError))
                            case .networkError:
                                completionForViewModel(.failure(.useCaseError))
                            }
                        }
                    }
                    return
                }
            } }
        
        completionForViewModel(.success(users))
    }
}
