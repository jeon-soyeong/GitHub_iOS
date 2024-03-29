//
//  TabBarController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import UIKit

import ReactorKit

final class TabBarController: UITabBarController {
    @Dependency var reactor: LoginReactor
    private var rootViewControllers: [UIViewController] = []
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupViewControllers()
        bind()
    }

    private func setupTabBar() {
        tabBar.tintColor = .white
        tabBar.barTintColor = .white
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .black
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupViewControllers() {
        var navigationControllers: [UIViewController] = []
        TabBar.allCases.forEach {
            let rootViewController = $0.rootViewController
            navigationControllers.append(createNavigationController(rootViewController: rootViewController,
                                                                    title: $0.title,
                                                                    image: $0.image))
            rootViewControllers.append(rootViewController)
        }
        setViewControllers(navigationControllers, animated: false)
        selectedIndex = 0
    }

    func bind() {
        bindAction()
        bindState()
    }

    private func bindAction() {
        typealias Action = LoginReactor.Action

        rootViewControllers.forEach {
            $0.navigationItem.rightBarButtonItem?.rx.tap
            .map {
                if KeychainManager.shared.readAccessToken(key: "accessToken") != nil {
                    return Action.didTappedLogoutButton
                } else {
                    return Action.didTappedLoginButton
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        }
    }

    private func bindState() {
        reactor.state
            .map { $0.isLogined }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoginSuccess in
                if isLoginSuccess {
                    self?.setupNavigationBarRightButtonItem(size: (width: 28, height: 28), imageName: "logout")
                }
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isLogout }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLogoutSuccess in
                if isLogoutSuccess {
                    self?.setupNavigationBarRightButtonItem(size: (width: 28, height: 28), imageName: "login")
                }
            })
            .disposed(by: disposeBag)
    }

    private func createNavigationController(rootViewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        setupTabBarItem(navigationController: navigationController, title: title, image: image)
        setupNavigationBar(navigationController: navigationController, rootViewController: rootViewController)
        
        return navigationController
    }

    private func setupTabBarItem(navigationController: UINavigationController, title: String, image: UIImage?) {
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        navigationController.tabBarItem.imageInsets = .init(top: 7, left: 0, bottom: 7, right: 0)
        navigationController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
    }

    private func setupNavigationBar(navigationController: UINavigationController, rootViewController: UIViewController) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .black
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.setFont(type: .medium, size: 24)
        ]
        navigationController.navigationBar.standardAppearance = navigationBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance

        rootViewController.navigationItem.title = "GitHub"

        var resizedImage: UIImage?
        if KeychainManager.shared.readAccessToken(key: "accessToken") != nil {
            resizedImage = UIImage(named: "logout")?.resize(size: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal)
        } else {
            resizedImage = UIImage(named: "login")?.resize(size: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal)
        }
        rootViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: resizedImage, style: .plain, target: self, action: nil)
    }

    func setupNavigationBarRightButtonItem(size: (width: Int, height: Int), imageName: String) {
        let resizedImage = UIImage(named: imageName)?.resize(size: CGSize(width: size.width, height: size.height)).withRenderingMode(.alwaysOriginal)
        self.rootViewControllers.forEach {
            $0.navigationItem.rightBarButtonItem?.image = resizedImage
        }
    }
}
