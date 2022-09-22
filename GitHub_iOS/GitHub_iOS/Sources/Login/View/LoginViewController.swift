//
//  LoginViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import UIKit

import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = LoginViewModel()

    private let loginLabel = UILabel().then {
        $0.text = "로그인이 필요합니다"
        $0.font = UIFont.setFont(type: .regular, size: 24)
    }

    private let loginButton = UIButton().then {
        let resizedImage = UIImage(named: "loginButton")?.resize(size: CGSize(width: 100, height: 100))
        $0.setImage(resizedImage, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindAction()
        setupNotification()
    }

    private func setupView() {
        view.backgroundColor = .white
        
        setupSubViews()
        setupConstraints()
        setupNavigationItem()
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

    private func setupNavigationItem() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "GitHub"
        let resizedImage = UIImage(named: "login")?.resize(size: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: resizedImage, style: .plain, target: self, action: nil)
    }

    private func bindAction() {
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.action.didTappedLoginButton.onNext(())
            })
            .disposed(by: disposeBag)

        self.navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.action.didTappedLoginButton.onNext(())
            })
            .disposed(by: disposeBag)
    }

    private func setupNotification() {
        NotificationCenter.default.rx.notification(.loginSuccess)
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: false)
            }).disposed(by: disposeBag)
    }
}
