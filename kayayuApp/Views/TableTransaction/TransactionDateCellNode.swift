//
//  TransactionDateCellNode.swift
//  kayayuApp
//
//  Created by Salsabila Azaria on 18/11/21.
//

import Foundation
import AsyncDisplayKit

class TransactionDateCellNode: ASDisplayNode {
	private let totalIncomeAmount: ASTextNode = ASTextNode()
	private let totalExpenseAmount: ASTextNode = ASTextNode()
	private let dateText: ASTextNode = ASTextNode()
	
	private let date: Date
	private let incomePerDay: Float
	private let expensePerDay: Float
	
	private let calendarHelper: CalendarHelper = CalendarHelper()
	private let numberHelper: NumberHelper = NumberHelper()
	
	init(date: Date = Date() , incomePerDay: Float = 0, expensePerDay: Float = 0) {
		self.date = date
		self.incomePerDay = incomePerDay
		self.expensePerDay = expensePerDay
		super.init()
		
		configureDatetext()
		configureIncomeAmount()
		configureExpenseAmount()
		borderWidth = 1
		borderColor = kayayuColor.softGrey.cgColor
		
		backgroundColor = .white
		automaticallyManagesSubnodes = true
		
		style.preferredSize = CGSize(width: UIScreen.main.bounds.width - 64, height: 30)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let incomeExpenseSpec = ASStackLayoutSpec(direction: .horizontal,
												  spacing: 8,
												  justifyContent: .end,
												  alignItems: .end,
												  children: [totalIncomeAmount, totalExpenseAmount])

		incomeExpenseSpec.style.flexGrow = 1

		let dateSpec = ASStackLayoutSpec(direction: .horizontal,
		spacing: 0,
								justifyContent: .center,
								alignItems: .center,
								children: [dateText])

		
		let mainSpec = ASStackLayoutSpec(direction: .horizontal,
										 spacing: 16,
										 justifyContent: .center,
										 alignItems: .center,
										 children: [dateSpec, incomeExpenseSpec])
		
		mainSpec.alignItems = .center
		
		mainSpec.style.preferredSize = CGSize(width: UIScreen.main.bounds.width - 24, height: 30)
		
		let insetMain = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0,
															   left: 8,
															   bottom: 0,
															   right: 8), child: mainSpec)
		
		return insetMain
	}
	
	private func configureDatetext() {
		let dayString = calendarHelper.dayOfDate(date: date)
		let monthString = calendarHelper.monthString(date: date)
		let formattedMonthString = monthString.prefix(3)

		dateText.attributedText = NSAttributedString.bold("\(dayString) \(formattedMonthString)", 15, .black)
		dateText.style.preferredSize = CGSize(width: 60, height: 20)
		dateText.style.alignSelf = .center
	}
	
	private func configureIncomeAmount() {
		let formattedAmount = numberHelper.floatToIdFormat(beforeFormatted: incomePerDay)
        
		totalIncomeAmount.attributedText = NSAttributedString.semibold("\(formattedAmount)", 14, .systemGreen)
	}
	
	private func configureExpenseAmount() {
		let formattedAmount = numberHelper.floatToIdFormat(beforeFormatted: expensePerDay)
        
        totalExpenseAmount.attributedText = NSAttributedString.semibold("\(formattedAmount)", 14, .systemRed)
	}
}
