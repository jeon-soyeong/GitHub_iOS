//
//  ProfileReactor.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/09.
//

import Foundation

import ReactorKit

final class ProfileReactor: Reactor {
    private let useCase: ProfileUseCase
    private let apiService: APIService

    enum Action {
        case fetch
        case loadMore
    }

    enum Mutation {
        case initialize
        case setUserData(User)
        case setUserStarRepositories([UserRepository])
        case appendUserStarRepositories([UserRepository])
        case setPage(Int)
        case setLoading(Bool)
    }

    struct State {
        var currentPage = 1
        var perPage = 20
        var isRequestCompleted = false
        var userData: User?
        var userStarRepositories: [UserRepository] = []
        var isLoading: Bool = false
    }

    let initialState = State()

    init(useCase: ProfileUseCase, apiService: APIService) {
        self.useCase = useCase
        self.apiService = apiService
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            let initialize: Observable<Mutation> = .just(.initialize)
            let startLoading: Observable<Mutation> = .just(.setLoading(true))
            let fetch = Observable.zip(self.useCase.getUserData(),
                                                  self.useCase.getUserStarRepositoryData(page: 1, perPage: self.currentState.perPage))
                .flatMap { user, userStarRepositories -> Observable<Mutation> in
                    return .concat([
                        .just(.setPage(self.currentState.currentPage + 1)),
                        .just(.setUserData(user)),
                        .just(.setUserStarRepositories(userStarRepositories)),
                        .just(.setLoading(false))
                    ])
                }
            return .concat(initialize, startLoading, fetch)
        case .loadMore:
            guard !self.currentState.isLoading else { return Observable.empty() }
            guard !self.currentState.isRequestCompleted else { return Observable.empty() }

            let startLoading: Observable<Mutation> = .just(.setLoading(true))
            let loadMore = self.useCase.getUserStarRepositoryData(page: self.currentState.currentPage, perPage: self.currentState.perPage)
                .flatMap { userStarRepositories -> Observable<Mutation> in
                    if self.currentState.isRequestCompleted == false {
                        return .concat([
                            .just(.setPage(self.currentState.currentPage + 1)),
                            .just(.appendUserStarRepositories(userStarRepositories)),
                            .just(.setLoading(false))
                        ])
                    } else {
                        return .just(.setLoading(false))
                    }
                }
            return .concat(startLoading, loadMore)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state

        switch mutation {
        case .initialize:
            newState.currentPage = 1
            newState.userStarRepositories = []
            newState.isRequestCompleted = false
        case .setUserData(let user):
            newState.userData = user
        case .setUserStarRepositories(let userStarRepositories):
            newState.userStarRepositories = userStarRepositories
        case .appendUserStarRepositories(let userStarRepositories):
            if userStarRepositories.isEmpty {
                newState.isRequestCompleted = true
            }
            newState.userStarRepositories.append(contentsOf: userStarRepositories)
        case .setPage(let page):
            newState.currentPage = page
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }

        return newState
    }
}
