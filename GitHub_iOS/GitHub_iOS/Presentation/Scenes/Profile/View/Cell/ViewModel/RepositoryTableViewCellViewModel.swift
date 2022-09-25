//
//  RepositoryTableViewCellViewModel.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/10.
//

import Foundation

import RxSwift
import RxRelay

final class RepositoryTableViewCellViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    private let apiService: APIService
    private let contentsLimitWidth = UIScreen.main.bounds.width - 100
    private let data: UserRepository
    private(set) var topics: [String] = []
    
    struct Action {
        let fetchTopics = PublishSubject<Void>()
        let didTappedStarButton = PublishSubject<(isRequestStar: Bool, fullName: String)>()
    }

    struct State {
        let topicsData = BehaviorRelay<[String]>(value: [])
        let starToggleResult = BehaviorRelay<Bool>(value: false)
    }

    var action = Action()
    var state = State()

    init(data: UserRepository, apiService: APIService) {
        self.data = data
        self.apiService = apiService
        self.configure()
    }

    private func configure() {
        action.fetchTopics
            .subscribe(onNext: { [weak self] _ in
                self?.fetchTopics()
            })
            .disposed(by: disposeBag)
        
        action.didTappedStarButton
            .subscribe(onNext: { [weak self] result in
                if result.isRequestStar {
                    self?.requestStar(fullName: result.fullName)
                } else {
                    self?.requestUnstar(fullName: result.fullName)
                }
            })
            .disposed(by: disposeBag)
    }

    private func fetchTopics() {
        if data.topics.count > 0 {
            let lastIndex = getFirstLineLastCellIndex(dataCount: data.topics.count)
            for i in 0...lastIndex {
                topics.append(data.topics[i])
            }
            state.topicsData.accept(topics)
        }
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
    
    private func requestStar(fullName: String) {
        apiService.request(GitHubAPI.requestStar(fullName: fullName))
            .subscribe(onNext: { [weak self] in
                self?.state.starToggleResult.accept($0.count == 0)
            }, onError: { [weak self] _ in
                self?.state.starToggleResult.accept(false)
            })
            .disposed(by: disposeBag)
    }

    private func requestUnstar(fullName: String) {
        apiService.request(GitHubAPI.requestUnstar(fullName: fullName))
            .subscribe(onNext: { [weak self] in
                self?.state.starToggleResult.accept($0.count == 0)
            }, onError: { [weak self] _ in
                self?.state.starToggleResult.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func calculateCellWidth(index: Int, fontSize: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = data.topics[index]
        label.font = UIFont.setFont(type: .medium, size: fontSize)
        label.sizeToFit()
        return label.frame.width
    }
}
