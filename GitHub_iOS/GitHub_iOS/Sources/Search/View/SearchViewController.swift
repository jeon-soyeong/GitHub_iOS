//
//  SearchViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import UIKit

import RxSwift
import RxCocoa
import RxRelay
import RxDataSources
import Then
import SnapKit

class SearchViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = SearchViewModel()
    
    private let searchBar = UISearchBar().then {
        $0.searchBarStyle = .minimal
        $0.searchTextField.layer.cornerRadius = 20
    }
    
    private lazy var searchRepositoryTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.scrollsToTop = true
        $0.isUserInteractionEnabled = true
    }
    
    lazy var dataSource = RxTableViewSectionedReloadDataSource<UserRepositorySection> {  [weak self] dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryTableViewCell", for: indexPath)
        let repositoryTableViewCell = cell as? RepositoryTableViewCell
        let isStarred = self?.viewModel.starredList.contains { $0.fullName == item.fullName } ?? false
        repositoryTableViewCell?.setupUI(data: item, isStarred: isStarred)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNotification()
        setupTableView()
        bindAction()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.action.viewWillAppear.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        initializeUI()
        viewModel.action.viewDisappear.onNext(())
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        setupSubViews()
        setupConstraints()
    }
    
    private func setupSubViews() {
        view.addSubviews([searchBar, searchRepositoryTableView])
    }
    
    private func setupConstraints() {
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().inset(120)
            $0.width.equalToSuperview().inset(18)
            $0.centerX.equalToSuperview()
        }
        
        searchRepositoryTableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(tabBarController?.tabBar.frame.size.height ?? 100)
        }
    }
    
    private func setupNotification() {
        NotificationCenter.default.rx.notification(.loginSuccess)
            .subscribe(onNext: { [weak self] _ in
                self?.initializeUI()
                self?.viewModel.action.didSearch.onNext((""))
                print("Search LOGIN noti 수신")
            }).disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(.logoutSuccess)
            .subscribe(onNext: { [weak self] _ in
                self?.initializeUI()
                self?.viewModel.action.didSearch.onNext((""))
                print("Search LOGOUT noti 수신")
            }).disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        searchRepositoryTableView.showsVerticalScrollIndicator = false
        searchRepositoryTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        searchRepositoryTableView.registerCell(cellType: RepositoryTableViewCell.self)
        searchRepositoryTableView.register(MyStarRepositoryTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID)
    }
    
    private func bindAction() {
        searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] _ in
                self?.viewModel.initialize()
                if let searchText = self?.searchBar.searchTextField.text {
                    print("searchText: \(searchText)")
                    self?.viewModel.action.didSearch.onNext((searchText))
                }
            }
            .disposed(by: self.disposeBag)

        searchRepositoryTableView.rx.prefetchRows
            .compactMap(\.last?.row)
            .withUnretained(self)
            .bind { [weak self] vc, row in
                if self?.viewModel.isRequestCompleted == false {
                    if let searchText = self?.searchBar.searchTextField.text,
                       let dataCount = self?.dataSource.sectionModels.first?.items.count,
                       row >= dataCount - 3,
                       self?.viewModel.isRequesting == false {
                        print("row: \(row)")
                        self?.viewModel.action.didSearch.onNext((searchText))
                    }
                }
            }
            .disposed(by: self.disposeBag)
    }

    private func bindViewModel() {
        viewModel.state.searchRepositoryData
            .bind(to: searchRepositoryTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func initializeUI() {
        searchBar.searchTextField.text = ""
        viewModel.initialize()
        searchRepositoryTableView.contentOffset = .zero
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}
