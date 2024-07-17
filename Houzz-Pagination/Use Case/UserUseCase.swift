//
//  UserUseCase.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//


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
        
        ids.forEach {
            dispatchGroup.enter()
            localRepo.loadUser(withID: $0) { [weak self] result in
                guard let self else { return }
                self.dispatchGroup.leave()
                
                switch result {
                case let .found(localDTO):
                    let user = User(fromLocalDTO: localDTO)
                    users.append(user)
                default:
                    return
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
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
            
            self.remoteRepo.requestUser(fromPage: page) { result in
                switch result {
                case let .success(userDTOs):
                    // save to store
                    for userDTO in userDTOs {
                        self.localRepo.saveUser(fromRemote: userDTO, completion: nil)
                    }
                    let users: [User] = userDTOs.map { .init(fromRemoteDTO: $0) }
                    completion(.success(users))
                case let .failure(repoError):
                    switch repoError {
                    case .failedToParseData:
                        completion(.failure(.parsingError))
                    case .networkError:
                        completion(.failure(.useCaseError))
                    }
                }
            }
        }
    }
}
