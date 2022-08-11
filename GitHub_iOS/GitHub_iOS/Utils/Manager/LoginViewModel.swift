//
//  LoginViewModel.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation
import RxSwift

class LoginViewModel {
    private let disposeBag = DisposeBag()
    
    var isLogined: Bool {
        if KeychainManager.shared.readAccessToken(key: "access_token") != nil {
            return true
        } else {
            return false
        }
    }
    
    struct Action {
        let didTappedLoginButton = PublishSubject<Void>()
        let login = PublishSubject<String>()
        let didTappedLogoutButton = PublishSubject<Void>()
    }
    
    struct State {
        let isLogined = BehaviorSubject<Bool>(value: false)
        let isLogout = BehaviorSubject<Bool>(value: false)
    }
    
    var action = Action()
    var state = State()
    
    init() {
        configure()
    }
    
    private func configure() {
        action.didTappedLoginButton
            .subscribe(onNext: {
                self.openGithubLogin()
            })
            .disposed(by: disposeBag)
        
        action.login
            .subscribe(onNext: { [weak self] code in
                self?.login(with: code)
                    .subscribe(onNext: { [weak self] result in
                        switch result {
                        case .success():
                            self?.state.isLogined.onNext(true)
                        case .failure(let error):
                            print(error)
                            self?.state.isLogined.onNext(false)
                        }
                    })
                    .disposed(by: self?.disposeBag ?? DisposeBag())
            })
            .disposed(by: disposeBag)
        
        action.didTappedLogoutButton
            .subscribe(onNext: {
                self.logout()
                    .subscribe(onNext: { [weak self] result in
                        switch result {
                        case .success():
                            print("logout 성공")
                            self?.state.isLogout.onNext(true)
                        case .failure(let error):
                            print(error)
                            self?.state.isLogout.onNext(false)
                        }
                    }).disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    private func openGithubLogin() {
        let scope = "repo,user"
        let urlString = "\(APIConstants.baseUrl)/login/oauth/authorize?client_id=\(APIConstants.clientID)&scope=\(scope)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func requestAccessToken(with code: String) -> Observable<Result<String, Error>> {
        return Observable.create() { [weak self] result in
            APIService.shared.request(GitHubAPI.requestAccessToken(code: code))
                .subscribe(onSuccess: { (response: [String: String]) in
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
    
    private func login(with code: String) -> Observable<Result<Void, Error>> {
        return Observable.create() { [weak self] result in
            self?.requestAccessToken(with: code)
                .subscribe(onNext: { response in
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
    
    private func logout() -> Observable<Result<Void, Error>> {
        return Observable.create() { result in
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
