//
//  HomeTableTransaction.swift
//  kayayuApp
//
//  Created by Salsabila Azaria on 18/11/21.
//

import Foundation
import AsyncDisplayKit

class HomeTableTransaction: ASDisplayNode {
	var changeMonthData: ((Date) -> Void)?
	var onDeleteData: ((Transactions) -> Void)?
	private let transactionTableHeader: TransactionTableHeaderNode
	private let transactionTableNode: TransactionTableNode
	private let viewModel: HomeViewModel
	
	private let calendarHelper: CalendarHelper = CalendarHelper()
	
	init(viewModel: HomeViewModel) {
		self.viewModel = viewModel
		self.transactionTableNode = TransactionTableNode(viewModel: viewModel)
		self.transactionTableHeader = TransactionTableHeaderNode(viewModel: viewModel)
		
		super.init()
		
		configureNode()
		backgroundColor = kayayuColor.softGrey
		automaticallyManagesSubnodes = true
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		let tableTransactionInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0,
																left: 16,
																bottom: 0,
																right: 16),
										   child: transactionTableNode)
		
		let tableSpec = ASStackLayoutSpec(direction: .vertical,
										 spacing: 10,
										 justifyContent: .start,
										 alignItems: .stretch,
										 children: [transactionTableHeader, tableTransactionInset])
		
		return tableSpec
	}
	
	private func configureNode() {
		transactionTableNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.55)

		transactionTableHeader.changeMonthData = { [weak self] date in
			guard let month = self?.calendarHelper.monthInt(date: date),
				  let year = self?.calendarHelper.yearInt(date: date),
				  let startDate = self?.calendarHelper.getSpecStartMonth(month: month, year: year),
				  let endDate = self?.calendarHelper.getSpecEndMonth(month: month, year: year) else {
				return
			}
			self?.viewModel.selectedDate.accept(date)
			self?.viewModel.getTransactionDataSpecMonth(startDate: startDate, endDate: endDate)
			
		}
		
		transactionTableNode.onDeleteData = { [weak self] transData in
			self?.onDeleteData?(transData)
		}
	}
	
}
