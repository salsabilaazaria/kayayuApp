//
//  SubscriptionViewController.swift
//  kayayuApp
//
//  Created by Salsabila Azaria on 12/7/21.
//


import Foundation
import AsyncDisplayKit

class SubscriptionViewController: ASDKViewController<ASDisplayNode> {
	
	private let subsNode: SubscriptionTableNode = SubscriptionTableNode()
	
	override init() {
		super.init(node: subsNode)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func configureNode() {

	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tabBarController?.navigationItem.title = "My Subscription"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "My Subscription"
	
		edgesForExtendedLayout = []
		self.navigationController?.navigationBar.prefersLargeTitles = false
		self.navigationController?.navigationBar.backgroundColor = .white

	}

}
