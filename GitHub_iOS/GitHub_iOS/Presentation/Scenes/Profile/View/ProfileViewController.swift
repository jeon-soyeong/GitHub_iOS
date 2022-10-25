//
//  ProfileViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import UIKit

import Then
import SnapKit
import ReactorKit

final class ProfileViewController: UIViewController, View {
    private let loginViewController = LoginViewController(reactor: LoginReactor(useCase: DefaultLoginUseCase(loginRepository: DefaultLoginRepository()),
                                                                                    apiService: APIService()))
    private let fetch = PublishSubject<Void>()
    var disposeBag = DisposeBag()

    private var myStarRepositoryTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.backgroundColor = .systemBackground
        $0.clipsToBounds = true
        $0.scrollsToTop = true
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var loadingIndicatorView = LoadingIndicatorView().then {
        $0.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        $0.center = view.center
    }

    init(reactor: ProfileReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupNotification()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if KeychainManager.shared.readAccessToken(key: "accessToken") == nil {
            self.navigationController?.pushViewController(loginViewController, animated: false)
        } else {
            let safeAreaTopHeight = view.safeAreaInsets.top
            myStarRepositoryTableView.contentOffset = CGPoint(x: 0, y: -Int(safeAreaTopHeight))
            fetch.onNext(())
        }
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        setupSubViews()
        setupConstraints()
    }

    private func setupSubViews() {
        view.addSubviews([myStarRepositoryTableView, loadingIndicatorView])
    }

    private func setupConstraints() {
        guard let tabBarSize = tabBarController?.tabBar.frame.size.height else {
            return
        }
        myStarRepositoryTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(tabBarSize)
        }
    }

    private func setupNotification() {
        NotificationCenter.default.rx.notification(.logoutSuccess)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.pushViewController(self.loginViewController, animated: false)
            }).disposed(by: disposeBag)
    }

    private func setupTableView() {
        myStarRepositoryTableView.showsVerticalScrollIndicator = false
        myStarRepositoryTableView.delegate = self
        myStarRepositoryTableView.registerCell(cellType: RepositoryTableViewCell.self)
        myStarRepositoryTableView.register(MyStarRepositoryTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID)
    }

    func bind(reactor: ProfileReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }

    private func bindAction(reactor: ProfileReactor) {
        typealias Action = ProfileReactor.Action

        fetch
            .map { Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        myStarRepositoryTableView.rx.prefetchRows
            .filter { $0.contains(where: { $0.row >= reactor.currentState.userStarRepositories.count - 3 }) }
            .map { _ in Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }

    private func bindState(reactor: ProfileReactor) {
        reactor.state
            .map { $0.userStarRepositories }
            .observe(on: MainScheduler.instance)
            .bind(to: myStarRepositoryTableView.rx.items(cellIdentifier: RepositoryTableViewCell.identifier, cellType: RepositoryTableViewCell.self)) { row, userRepository, cell in
                cell.configure(viewModel: RepositoryTableViewCellViewModel(data: userRepository,
                                                                           useCase: DefaultStarUseCase(starRepository: DefaultStarRepository()),
                                                                           apiService: APIService()))
                cell.setupUI(data: userRepository, isStarred: true)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isLoading }
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showActivityIndicator()
                } else {
                    self?.hideActivityIndicator()
                }
            })
            .disposed(by: disposeBag)
    }

    private func bindState(reactor: ProfileReactor, to headerView: MyStarRepositoryTableViewHeaderView?) {
        reactor.state
            .map { $0.userData }
            .distinctUntilChanged()
            .subscribe(onNext: { (user: User?) in
                headerView?.setupUI(data: user)
            }).disposed(by: disposeBag)
    }

    private func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = false
            self.loadingIndicatorView.startAnimation()
        }
    }

    private func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = true
        }
    }
}

// MARK: UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID)
        let myStarRepositoryTableViewHeaderView = headerView as? MyStarRepositoryTableViewHeaderView
        if let reactor = reactor {
            bindState(reactor: reactor, to: myStarRepositoryTableViewHeaderView)
        }
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 132 : .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
}
