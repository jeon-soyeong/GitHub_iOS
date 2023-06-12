//
//  LoginViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import UIKit

import ReactorKit

final class LoginViewController: UIViewController {
    @Dependency var reactor: LoginReactor
    var disposeBag = DisposeBag()

    private let loginLabel = UILabel().then {
        $0.text = "로그인이 필요합니다"
        $0.font = UIFont.setFont(type: .regular, size: 24)
    }

    private let loginButton = UIButton().then {
        let resizedImage = UIImage(named: "loginButton")?.resize(size: CGSize(width: 100, height: 100))
        $0.setImage(resizedImage, for: .normal)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupNavigationItem()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNotification()
    }

    private func setupNavigationItem() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "GitHub"
        let resizedImage = UIImage(named: "login")?.resize(size: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: resizedImage, style: .plain, target: self, action: nil)
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        
        setupSubViews()
        setupConstraints()
    }

    private func setupSubViews() {
        view.addSubviews([loginLabel, loginButton])
    }

    private func setupConstraints() {
        loginLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(loginButton.snp.top).offset(-10)
        }

        loginButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

    func bind() {
        bindAction()
    }

    private func bindAction() {
        typealias Action = LoginReactor.Action

        loginButton.rx.tap
            .map { Action.didTappedLoginButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        self.navigationItem.rightBarButtonItem?.rx.tap
            .map { Action.didTappedLoginButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func setupNotification() {
        NotificationCenter.default.rx.notification(.loginSuccess)
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: false)
            }).disposed(by: disposeBag)
    }
}
