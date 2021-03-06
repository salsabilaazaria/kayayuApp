//
//  KayayuCoordinator.swift
//  kayayuApp
//
//  Created by Salsabila Azaria on 19/11/21.
//

import Foundation
import UIKit

public final class KayayuCoordinator {
	
	private var navigationController: UINavigationController
	private let tabBarViewController: UITabBarController
	var screen: KayayuScreen?
	private let window: UIWindow
	
	// MARK: - Init
	
	init(window: UIWindow) {
		self.tabBarViewController = UITabBarController()
		self.navigationController = UINavigationController()
		self.window = window
		self.window.backgroundColor = .white
	}
	
	func makeKayayuScreen() {
		window.rootViewController = navigationController
		window.makeKeyAndVisible()
		let screen = KayayuScreen(navigationController: self.navigationController, tabBarController: tabBarViewController)
		self.screen = screen
		self.configureScreen()
		
		DispatchQueue.main.async { [weak self] in
			self?.navigationController.pushViewController(screen.make(), animated: true)
		}
	}
	
	private func configureScreen() {
		screen?.onNavigationEvent = { [weak self] (navigationEvent: KayayuScreen.NavigationEvent) in
			
			guard let self = self, let screen = self.screen else {
				return
			}
			
			switch navigationEvent {
			case .onCreateTabBar(let authenticationViewModel):
				DispatchQueue.main.async {
					let homeViewModel = HomeViewModel()
					let statsViewModel = StatsViewModel()
					let profileViewModel = ProfileViewModel()
					let controller = screen.makeTabBarViewController(homeViewModel: homeViewModel, statsViewModel: statsViewModel, authViewModel: authenticationViewModel, profileViewModel: profileViewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenHomePage:
				DispatchQueue.main.async {
					let controller = self.tabBarViewController
					self.navigationController.popToViewController(controller, animated: true)
				}
				
			case .onOpenLandingPage:
				DispatchQueue.main.async {
					let controller = screen.makeLandingPageViewController()
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenLoginPage:
				DispatchQueue.main.async {
					let viewModel = AuthenticationViewModel()
					let controller = screen.makeLoginPageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenRegisterPage:
				DispatchQueue.main.async {
					let viewModel = AuthenticationViewModel()
					let controller = screen.makeRegisterPageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenStatsPage(let viewModel):
				DispatchQueue.main.async {
					let controller = screen.makeStatsPageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenAddRecordPage(let viewModel):
				DispatchQueue.main.async {
					let controller = screen.makeAddRecordPageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenProfilePage(let authViewModel, let profileViewModel):
				DispatchQueue.main.async {
					let controller = screen.makeProfileViewController(authViewModel: authViewModel, profileViewModel: profileViewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenSubscriptionPage(let viewModel):
				DispatchQueue.main.async {
					let controller = screen.makeSubscriptionPageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenInstallmentPage(let viewModel):
				DispatchQueue.main.async {
					let controller = screen.makeInstallmentPageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenHelp:
				DispatchQueue.main.async {
					let controller = screen.makeTheoryExplanationViewController()
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenEditProfile(let viewModel):
				DispatchQueue.main.async {
					let controller = screen.makeEditProfilePageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
			
			case .onBackToEditProfilePage:
				DispatchQueue.main.async {
					self.navigationController.popViewController(animated: true)
				}
				
			case .onOpenChangeEmail(let viewModel):
				DispatchQueue.main.async {
					let controller = screen.makeChangeEmailPageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenChangeUsername(let viewModel):
				DispatchQueue.main.async {
					let controller = screen.makeChangeUsernamePageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
				
			case .onOpenChangePassword(let viewModel):
				DispatchQueue.main.async {
					let controller = screen.makeChangePasswordPageViewController(viewModel: viewModel)
					self.navigationController.pushViewController(controller, animated: true)
				}
			}
		}
	}
}
