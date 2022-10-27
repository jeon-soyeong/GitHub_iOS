//
//  RepositoryTableViewCellReactor.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/10.
//

import Foundation

import ReactorKit

final class RepositoryTableViewCellReactor: Reactor {
    private let data: UserRepository
    private let useCase: StarUseCase
    private let apiService: APIService
    private let contentsLimitWidth = UIScreen.main.bounds.width - 100
    private(set) var topics: [String] = []
    
    enum Action {
        case fetchTopics
        case didTappedStarButton((isRequestStar: Bool, fullName: String?))
    }

    enum Mutation {
        case setTopics([String])
        case setStarToggleResult(Bool)
    }

    struct State {
        var topics: [String] = []
        var starToggleResult = false
    }

    let initialState = State()

    init(data: UserRepository, useCase: StarUseCase, apiService: APIService) {
        self.data = data
        self.useCase = useCase
        self.apiService = apiService
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchTopics:
            return fetchTopics()
        case .didTappedStarButton((let isRequestStar, let fullName)):
            if isRequestStar {
                return requestStar(fullName: fullName ?? "")
            } else {
                return requestUnstar(fullName: fullName ?? "")
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state

        switch mutation {
        case .setTopics(let topics):
            newState.topics = topics
        case .setStarToggleResult(let result):
            newState.starToggleResult = result
        }
        
        return newState
    }

    private func requestStar(fullName: String) -> Observable<Mutation> {
        useCase.requestStar(fullName: fullName)
            .flatMap { starResult -> Observable<Mutation> in
                return .just(.setStarToggleResult(starResult.count == 0))
            }
    }

    private func requestUnstar(fullName: String) -> Observable<Mutation> {
        useCase.requestUnstar(fullName: fullName)
            .flatMap { unStarResult -> Observable<Mutation> in
                return .just(.setStarToggleResult(unStarResult.count == 0))
            }
    }

    private func fetchTopics() -> Observable<Mutation> {
        if data.topics.count > 0 {
            let lastIndex = getFirstLineLastCellIndex(dataCount: data.topics.count)
            for i in 0...lastIndex {
                topics.append(data.topics[i])
            }
        }
        return .just(.setTopics(topics))
    }

    private func getFirstLineLastCellIndex(dataCount: Int) -> Int {
        var totalCellWidth: CGFloat = 0
        var resultIndex = 0
        for i in 0..<dataCount {
            let cellPadding: CGFloat = 12
            let cellLineSpacing: CGFloat = 4
            let cellWidth = calculateCellWidth(index: i, fontSize: 12) + cellPadding + cellLineSpacing
            totalCellWidth += cellWidth
            if totalCellWidth >= contentsLimitWidth {
                resultIndex = i - 1
                break
            } else {
                if i == dataCount - 1 {
                    resultIndex = i
                }
            }
        }
        return resultIndex
    }

    func calculateCellWidth(index: Int, fontSize: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = data.topics[index]
        label.font = UIFont.setFont(type: .medium, size: fontSize)
        label.sizeToFit()
        return label.frame.width
    }
}
