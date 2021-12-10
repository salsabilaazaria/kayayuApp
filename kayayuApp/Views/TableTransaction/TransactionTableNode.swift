//
//  TransactionTableNode.swift
//  kayayuApp
//
//  Created by Salsabila Azaria on 15/11/21.
//

import Foundation
import AsyncDisplayKit

class TransactionTableNode: ASTableNode {
	private let viewModel: HomeViewModel
	private let calendarHelper: CalendarHelper = CalendarHelper()
	
	init(viewModel: HomeViewModel) {
		self.viewModel = viewModel
		super.init(style: .plain)
		self.delegate = self
		self.dataSource = self
		configureObserver()
		backgroundColor = .white
		contentInset.bottom = 100
	}
	
	private func configureObserver() {
		viewModel.reloadUI = {
			self.reloadData()
		}
	}
	
}

extension TransactionTableNode: ASTableDataSource, ASTableDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		guard let count = viewModel.dictTransactionData.value?.count else {
			return 1
		}
		return count
	}
	
	// table view need to change by sections after array of data is grouped by day
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		guard let transData = viewModel.dictTransactionData.value,
			  let count = transData[section].transaction?.count else {
			return 1
		}
		return count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let allData = viewModel.dictTransactionData.value else {
			return UIView()
		}
		let sectionData = allData[section]
		
		guard let dateComponents = sectionData.date,
			  let date = Calendar.current.date(from: dateComponents) else {
			return UIView()
		}
		
		let incomePerDay = viewModel.calculateIncomePerDay(date: date)
		let expensePerDay = viewModel.calculateExpensePerDay(date: date)
		
		let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)
		let view = UIView(frame: rect)
		
		let cell = TransactionDateCellNode(date: date, incomePerDay: incomePerDay, expensePerDay: expensePerDay)
		cell.view.frame = rect
		view.addSubview(cell.view)
		
		cell.setNeedsLayout()
		cell.layoutIfNeeded()
		view.setNeedsLayout()
		view.layoutIfNeeded()
		return view
	}
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		guard let allData = viewModel.dictTransactionData.value else {
			return ASCellNode()
		}
		
		let sectionData = allData[indexPath.section]
		
		guard let transactionsData = sectionData.transaction?[indexPath.row],
			  let isIncomeTransaction = transactionsData.income_flag else {
			return ASCellNode()
		}
		
		let cell = TransactionCellNode(isIncomeTransaction: isIncomeTransaction, data: transactionsData)
		
		return cell
	}
	
	func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			guard let tempTransactionsData = viewModel.transactionsData.value else {
				return
			}
			//			viewModel.deleteTransactionData(transactionDelete: tempTransactionsData[indexPath.row])
			//
			//			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
	
}

