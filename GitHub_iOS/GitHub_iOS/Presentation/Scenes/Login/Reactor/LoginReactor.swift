//
//  LoginReactor.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation
import ReactorKit

final class LoginReactor: Reactor {
    @Dependency var useCase: LoginUseCase

    enum Action {
        case didTappedLoginButton
        case login(String)
        case didTappedLogoutButton
    }

    enum Mutation {
        case setLogin(Bool)
        case setLogout(Bool)
    }

    struct State {
        var isLogined: Bool = false
        var isLogout: Bool = false
    }

    let initialState: State = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTappedLoginButton:
            return openGithubLogin()
        case .login(let code):
            return requestAccessToken(with: code)
        case .didTappedLogoutButton:
            return logout()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state

        switch mutation {
        case .setLogin(let isLogin):
            newState.isLogined = isLogin
        case .setLogout(let isLogout):
            newState.isLogout = isLogout
        }
        return newState
    }

    private func openGithubLogin() -> Observable<Mutation> {
        let scope = "repo,user"
        let urlString = "\(APIConstants.githubLoginBaseURL)/login/oauth/authorize?client_id=\(APIConstants.clientID)&scope=\(scope)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        return .just(.setLogin(false))
    }

    private func requestAccessToken(with code: String) -> Observable<Mutation> {
        useCase.getAccessToken(code: code)
            .flatMap { response -> Observable<Mutation> in
                let accessToken = response.accessToken
                if KeychainManager.shared.addAccessToken(key: "accessToken", value: accessToken) {
                    print("accessToken: \(accessToken)")
                    NotificationCenter.default.post(name: .loginSuccess, object: nil)
                    return .concat([
                        .just(.setLogout(false)),
                        .just(.setLogin(true))
                    ])
                } else {
                    return .just(.setLogin(false))
                }
            }
    }

    private func logout() -> Observable<Mutation> {
        if KeychainManager.shared.deleteAccessToken(key: "accessToken") {
            NotificationCenter.default.post(name: .logoutSuccess, object: nil)
            return .concat([
                .just(.setLogin(false)),
                .just(.setLogout(true))
            ])
        } else {
            return .just(.setLogout(false))
        }
    }
}
