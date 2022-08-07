//
//  LoginManager.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation
import RxSwift

class LoginManager {
    static let shared = LoginManager()
    
    private let disposeBag = DisposeBag()
    
    var isLogined: Bool {
        if KeychainManager.shared.readAccessToken(key: "access_token") != nil {
            return true
        } else {
            return false
        }
    }
    
    private init() {}

    private func requestAccessToken(with code: String) -> Observable<Result<String, Error>> {
        return Observable.create() { [weak self] result in
            APIService.shared.request(GitHubAPI.requestAccessToken(code: code))
                .subscribe(onSuccess: { [weak self] (response: [String: String]) in
                    if let accessToken = response["access_token"] {
                        print("accessToken: \(accessToken)")
                        result.onNext(.success(accessToken))
                    } else {
                        result.onNext(.failure(LoginError.notExistsAccessToken))
                    }
                }, onFailure: {
                    result.onNext(.failure($0))
                })
                .disposed(by: self?.disposeBag ?? DisposeBag())
            
            return Disposables.create()
        }
    }
}

extension LoginManager {
    func openGithubLogin() {
        let scope = "repo,user"
        let urlString = "\(APIConstants.baseUrl)/login/oauth/authorize?client_id=\(APIConstants.clientID)&scope=\(scope)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func login(with code: String) -> Observable<Result<Void, Error>> {
        return Observable.create() { [weak self] result in
            self?.requestAccessToken(with: code)
                .subscribe(onNext: { [weak self] response in
                    switch response {
                    case .success(let accessToken):
                        if KeychainManager.shared.addAccessToken(key: "accessToken", value: accessToken) {
                            result.onNext(.success(()))
                        } else {
                            result.onNext(.failure((LoginError.failedToSaveKeychain)))
                        }
                    case .failure(let error):
                        print(error)
                        result.onNext(.failure((LoginError.failedToGetAccessToken)))
                    }
                }).disposed(by: self?.disposeBag ?? DisposeBag())
            
            return Disposables.create()
        }
    }
    
    func logout() -> Observable<Result<Void, Error>> {
        return Observable.create() { [weak self] result in
            if KeychainManager.shared.deleteAccessToken(key: "accessToken") {
                result.onNext(.success(()))
                NotificationCenter.default.post(name: .logoutSuccess, object: nil)
            } else {
                result.onNext(.failure((LoginError.failedLogout)))
            }
            
            return Disposables.create()
        }
    }
}
