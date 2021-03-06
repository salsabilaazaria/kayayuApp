//
//  InstallmentCellNode.swift
//  kayayuApp
//
//  Created by Salsabila Azaria on 12/7/21.
//


import Foundation
import AsyncDisplayKit

class InstallmentCellNode: ASCellNode {
	private let installmentName: ASTextNode = ASTextNode()
	private let interest: ASTextNode = ASTextNode()
	private let billingDateInstallment: ASTextNode = ASTextNode()
	private let typeInstallment: ASTextNode = ASTextNode()
	private let totalAmount: ASTextNode = ASTextNode()
	private let remainingAmount: ASTextNode = ASTextNode()
	private let endDateInstallment: ASTextNode = ASTextNode()
	private let dueDate: ASTextNode = ASTextNode()
    
    private let instlData: RecurringTransactions
    private let nextBillDate: Date
    private let remainingAmountValue: Float
    private let dueIn: Int
    
    private let calendarHelper = CalendarHelper()
	private let numberHelper = NumberHelper()
    
    init(data: RecurringTransactions, nextBillDate: Date, remainingAmount: Float, dueIn: Int) {
        self.instlData = data
        self.nextBillDate = nextBillDate
        self.remainingAmountValue = remainingAmount
        self.dueIn = dueIn
		super.init()
		
		configureInformation()
		
		backgroundColor = .white
		automaticallyManagesSubnodes = true
	}
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

		let mainSpec = ASStackLayoutSpec(direction: .vertical,
										 spacing: 0,
										 justifyContent: .start,
										 alignItems: .start,
										 children: [createInfoSpec(), createDueDate()])
		
		let insetMainSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16), child: mainSpec)
		
		return insetMainSpec
	}
	
	private func createInfoSpec() -> ASLayoutSpec {
		configureInformation()
		let backgroundNode: ASDisplayNode = ASDisplayNode()
		backgroundNode.backgroundColor = .clear
		backgroundNode.borderColor = kayayuColor.softGrey.cgColor
		backgroundNode.borderWidth = 1
		
		let textSpec = ASStackLayoutSpec(direction: .vertical,
										 spacing: 4,
										 justifyContent: .start,
										 alignItems: .start,
										 children: [installmentName, interest, billingDateInstallment, typeInstallment, remainingAmount, totalAmount,endDateInstallment])
		let insetTextSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16), child: textSpec)
		
		backgroundNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height/5)
		
		let infoSpec = ASOverlayLayoutSpec(child: backgroundNode, overlay: insetTextSpec)
		
		return infoSpec
	}
	
	private func createDueDate() -> ASLayoutSpec {
		let backgroundNode: ASDisplayNode = ASDisplayNode()
		backgroundNode.backgroundColor = .clear
		backgroundNode.borderColor = kayayuColor.softGrey.cgColor
		backgroundNode.borderWidth = 1
		
		let textSpec = ASStackLayoutSpec(direction: .vertical,
										 spacing: 4,
										 justifyContent: .start,
										 alignItems: .start,
										 children: [dueDate])
		let insetTextSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16), child: textSpec)
		
		backgroundNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width , height: 40)
		
		let infoSpec = ASOverlayLayoutSpec(child: backgroundNode, overlay: insetTextSpec)
		
		return infoSpec
	}
	
	private func configureInformation() {
        installmentName.attributedText = NSAttributedString.bold("\(instlData.description ?? " ")", 14, .black)
		
        interest.attributedText = NSAttributedString.normal("Interest: \(instlData.interest ?? 0)%", 14, .black)
		
        billingDateInstallment.attributedText = NSAttributedString.normal("Billing Date: \(calendarHelper.formatFullDate(date: nextBillDate))", 14, .black)
		
		typeInstallment.attributedText = NSAttributedString.normal("Billed: \(instlData.billing_type?.capitalized ?? " ")", 14, .black)
		
        let formattedRemaingingAmount = numberHelper.floatToIdFormat(beforeFormatted: remainingAmountValue)
        remainingAmount.attributedText = NSAttributedString.normal("Remaining Amount: \(formattedRemaingingAmount)", 14, .black)
        
		let formattedInstallmentAmount = numberHelper.floatToIdFormat(beforeFormatted: instlData.total_amount ?? 0)
        totalAmount.attributedText = NSAttributedString.normal("Total Amount: \(formattedInstallmentAmount)", 14, .black)
		
		endDateInstallment.attributedText = NSAttributedString.normal("End of Installment Date: \(calendarHelper.formatFullDate(date: instlData.end_billing_date ?? Date()))", 14, .black)
		
		dueDate.attributedText = NSAttributedString.normal("Due in: \(dueIn) days", 14, .black)
	}
	
}

