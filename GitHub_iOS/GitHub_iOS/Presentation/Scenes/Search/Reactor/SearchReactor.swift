//
//  SearchReactor.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/10.
//

import Foundation

import ReactorKit

final class SearchReactor: Reactor {
    private let useCase: SearchUseCase
    private let apiService: APIService

    enum Action {
        case initialize
        case didSearch(String?)
        case loadMore
    }

    enum Mutation {
        case setInitialize
        case setQuery(String?)
        case appendSearchRepositories(RepositoryInfo?)
        case setPage(Int)
        case setNoSearchResult(Bool)
        case setLoading(Bool)
    }

    struct State {
        var currentPage = 1
        var perPage = 20
        var noSearchResult = false
        var query: String?
        var isRequestCompleted = false
        var searchRepositories: [UserRepository] = []
        var isLoading = false
    }

    let initialState = State()

    init(useCase: SearchUseCase, apiService: APIService) {
        self.useCase = useCase
        self.apiService = apiService
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case.initialize:
            return .just(.setInitialize)
        case .didSearch(let query):
            let setInitialize: Observable<Mutation> = .just(.setInitialize)
            let setQuery: Observable<Mutation> = .just(.setQuery(query))
            let startLoading: Observable<Mutation> = .just(.setLoading(true))

            return .concat(setInitialize, setQuery, startLoading, requestSearchRepository(query: query ?? ""))
        case .loadMore:
            guard !self.currentState.isLoading else { return Observable.empty() }
            guard !self.currentState.isRequestCompleted else { return Observable.empty() }
            let startLoading: Observable<Mutation> = .just(.setLoading(true))

            return .concat(startLoading, requestSearchRepository(query: currentState.query ?? ""))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state

        switch mutation {
        case .setInitialize:
            newState.currentPage = 1
            newState.searchRepositories = []
            newState.isRequestCompleted = false
            newState.noSearchResult = false
        case .setQuery(let query):
            newState.query = query
        case .appendSearchRepositories(let searchRepositories):
            guard let searchRepositories = searchRepositories else {
                return state
            }
            newState.searchRepositories.append(contentsOf: searchRepositories.items)
            if searchRepositories.totalCount <= newState.searchRepositories.count {
                newState.isRequestCompleted = true
            }
        case .setPage(let page):
            newState.currentPage = page
        case .setNoSearchResult(let result):
            newState.noSearchResult = result
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }

        return newState
    }

    private func requestSearchRepository(query: String) -> Observable<Mutation> {
        return useCase.getSearchRepositoryData(page: currentState.currentPage, perPage: currentState.perPage, query: query)
            .flatMap { searchRepositories -> Observable<Mutation> in
                if searchRepositories.totalCount == 0 {
                    return .concat([
                        .just(.setNoSearchResult(true)),
                        .just(.setLoading(false))
                    ])
                }
                return .concat([
                    .just(.setPage(self.currentState.currentPage + 1)),
                    .just(.appendSearchRepositories(searchRepositories)),
                    .just(.setLoading(false))
                ])
        }
    }
}
