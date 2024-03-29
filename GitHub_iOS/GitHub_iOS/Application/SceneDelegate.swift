//
//  SceneDelegate.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/05.
//

import UIKit

import ReactorKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var tabBarController: TabBarController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        registerDependencies()
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        tabBarController = TabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let code = URLContexts.first?.url.absoluteString.components(separatedBy: "code=").last else {
            tabBarController?.showToast(message: "로그인 재시도 바랍니다.")
            return
        }

        @Dependency var loginReactor: LoginReactor
        loginReactor.action.onNext(.login(code))
    }
                 
    private func registerDependencies() {
        let container = DIContainer.shared
        
        container.register(type: LoginRepository.self, service: DefaultLoginRepository())
        container.register(type: SearchRepository.self, service: DefaultSearchRepository())
        container.register(type: ProfileRepository.self, service: DefaultProfileRepository())
        container.register(type: StarRepository.self, service: DefaultStarRepository())
        
        container.register(type: LoginUseCase.self, service: DefaultLoginUseCase())
        container.register(type: SearchUseCase.self, service: DefaultSearchUseCase())
        container.register(type: ProfileUseCase.self, service: DefaultProfileUseCase())
        container.register(type: StarUseCase.self, service: DefaultStarUseCase())
        
        container.register(type: LoginReactor.self, service: LoginReactor())
        container.register(type: SearchReactor.self, service: SearchReactor())
        container.register(type: ProfileReactor.self, service: ProfileReactor())
        
        container.register(type: LoginViewController.self, service: LoginViewController())
        container.register(type: SearchViewController.self, service: SearchViewController())
        container.register(type: ProfileViewController.self, service: ProfileViewController())
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
