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
    
    init(remoteRepo: UserRemoteRepositoryProtocol) {
        self.remoteRepo = remoteRepo
    }
    
    func loadUser(fromPage page: Int, completionForViewModel: @escaping ((Result<[User], UserUseCaseError>) -> Void)) {
        remoteRepo.requestUser(fromPage: page) { result in
            switch result {
            case let .success(userDTOs):
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
    }
}
