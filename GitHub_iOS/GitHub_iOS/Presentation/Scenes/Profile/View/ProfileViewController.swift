//
//  ProfileViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class ProfileViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: ProfileViewModel
    private let loginViewController = LoginViewController(viewModel: LoginViewModel(useCase: DefaultLoginUseCase(loginRepository: DefaultLoginRepository()), apiService: APIService()))

    private var myStarRepositoryTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.scrollsToTop = true
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var loadingIndicatorView = LoadingIndicatorView().then {
        $0.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        $0.center = view.center
        $0.isHidden = true
    }

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        if KeychainManager.shared.readAccessToken(key: "accessToken") == nil {
            self.navigationController?.pushViewController(loginViewController, animated: false)
        } else {
            let safeAreaTopHeight = view.safeAreaInsets.top
            myStarRepositoryTableView.contentOffset = CGPoint(x: 0, y: -Int(safeAreaTopHeight))
            viewModel.initialize()
            viewModel.action.fetch.onNext(())
        }
    }

    private func setupView() {
        view.backgroundColor = .white

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
        myStarRepositoryTableView.dataSource = self
        myStarRepositoryTableView.delegate = self
        myStarRepositoryTableView.registerCell(cellType: RepositoryTableViewCell.self)
        myStarRepositoryTableView.register(MyStarRepositoryTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID)
    }

    private func bindAction() {
        myStarRepositoryTableView.rx.prefetchRows
            .compactMap(\.last?.row)
            .bind { [weak self] row in
                if let dataCount = self?.viewModel.userRepository.count,
                   row >= dataCount - 3 {
                    self?.viewModel.action.fetch.onNext(())
                }
            }
            .disposed(by: self.disposeBag)
    }

    private func bindViewModel() {
        viewModel.state.userStarRepositoryData
            .subscribe(onNext: { [weak self] _ in
                self?.myStarRepositoryTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.state.isRequesting
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isRequesting in
                if isRequesting {
                    self?.showActivityIndicator()
                } else {
                    self?.hideActivityIndicator()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel(to headerView: MyStarRepositoryTableViewHeaderView?) {
        viewModel.state.userData
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

// MARK: UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.userRepository.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(cellType: RepositoryTableViewCell.self, indexPath: indexPath),
              indexPath.item < viewModel.userRepository.count else {
            return UITableViewCell()
        }
        
        cell.configure(viewModel: RepositoryTableViewCellViewModel(data: viewModel.userRepository[indexPath.row], apiService: APIService()))
        cell.setupUI(data: viewModel.userRepository[indexPath.row], isStarred: true)
        cell.selectionStyle = .none
        
        return cell
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
        bindViewModel(to: myStarRepositoryTableViewHeaderView)
        
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
