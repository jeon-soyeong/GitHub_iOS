//
//  LoginViewModel.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation
import RxSwift
import RxRelay

final class LoginViewModel: ViewModelType {
    var disposeBag = DisposeBag()

    struct Action {
        let login = PublishSubject<String>()
        let didTappedLoginButton = PublishSubject<Void>()
        let didTappedLogoutButton = PublishSubject<Void>()
    }

    struct State {
        let isLogined = BehaviorRelay<Bool>(value: false)
        let isLogout = BehaviorRelay<Bool>(value: false)
    }

    var action = Action()
    var state = State()

    init() {
        configure()
    }

    private func configure() {
        action.didTappedLoginButton
            .subscribe(onNext: { [weak self] in
                self?.openGithubLogin()
            })
            .disposed(by: disposeBag)

        action.login
            .subscribe(onNext: { [weak self] code in
                guard let self = self else { return }
                self.requestAccessToken(with: code)
            })
            .disposed(by: disposeBag)

        action.didTappedLogoutButton
            .subscribe(onNext: {
                self.logout()
            })
            .disposed(by: disposeBag)
    }

    private func openGithubLogin() {
        let scope = "repo,user"
        let urlString = "\(APIConstants.githubLoginBaseURL)/login/oauth/authorize?client_id=\(APIConstants.clientID)&scope=\(scope)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func requestAccessToken(with code: String) {
        APIService.shared.request(GitHubAPI.getAccessToken(code: code))
            .subscribe(onSuccess: { [weak self] (response: [String: String]) in
                if let accessToken = response["access_token"],
                   KeychainManager.shared.addAccessToken(key: "accessToken", value: accessToken) {
                    print("accessToken: \(accessToken)")
                    self?.state.isLogined.accept(true)
                    NotificationCenter.default.post(name: .loginSuccess, object: nil)
                } else {
                    self?.state.isLogined.accept(false)
                }
            }, onFailure: { _ in 
                self.state.isLogined.accept(false)
            })
            .disposed(by: self.disposeBag)
    }

    private func logout() {
        if KeychainManager.shared.deleteAccessToken(key: "accessToken") {
            state.isLogout.accept(true)
            NotificationCenter.default.post(name: .logoutSuccess, object: nil)
        } else {
            state.isLogout.accept(false)
        }
    }
}
