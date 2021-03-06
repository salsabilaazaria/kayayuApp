//
//  StatsViewModel.swift
//  kayayuApp
//
//  Created by Salsabila Azaria on 24/12/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import RxCocoa
import RxSwift


class StatsViewModel {
	var reloadUI: (() -> Void)?
	
	private let database = Firestore.firestore()
	private let calendarHelper: CalendarHelper = CalendarHelper()
	
	var user: BehaviorRelay<Users?> = BehaviorRelay<Users?>(value: nil)
	
	var needsTransactionData: BehaviorRelay<[Transactions]?> = BehaviorRelay<[Transactions]?>(value: nil)
	var wantsTransactionData: BehaviorRelay<[Transactions]?> = BehaviorRelay<[Transactions]?>(value: nil)
	var savingsTransactionData: BehaviorRelay<[Transactions]?> = BehaviorRelay<[Transactions]?>(value: nil)
	
	var needsTotalExpense: BehaviorRelay<Float?> = BehaviorRelay<Float?>(value: nil)
	var wantsTotalExpense: BehaviorRelay<Float?> = BehaviorRelay<Float?>(value: nil)
	var savingsTotalExpense: BehaviorRelay<Float?> = BehaviorRelay<Float?>(value: nil)
	
	var allTotalIncome: BehaviorRelay<Float?> = BehaviorRelay<Float?>(value: nil)
	var needsTotalIncome: BehaviorRelay<Float?> = BehaviorRelay<Float?>(value: nil)
	var wantsTotalIncome: BehaviorRelay<Float?> = BehaviorRelay<Float?>(value: nil)
	var savingsTotalIncome: BehaviorRelay<Float?> = BehaviorRelay<Float?>(value: nil)
	
	private let disposeBag = DisposeBag()
	
	init() {
		self.getUserData()
		
		let currStartDate = calendarHelper.getSpecStartMonth(month: calendarHelper.monthInt(date: Date()), year: calendarHelper.yearInt(date: Date()))
		let currEndDate = calendarHelper.getSpecEndMonth(month: calendarHelper.monthInt(date: Date()), year: calendarHelper.yearInt(date: Date()))
		
		self.getNeedsTransDataSpecMonth(startDate: currStartDate, endDate: currEndDate)
		self.getWantsTransDataSpecMonth(startDate: currStartDate, endDate: currEndDate)
		self.getSavingsTransDataSpecMonth(startDate: currStartDate, endDate: currEndDate)
		self.getAllIncomeData(startDate: currStartDate, endDate: currEndDate)
		
		configureObserver()
	}
	
	private func configureObserver() {
		Observable.combineLatest(
								 savingsTotalExpense.asObservable(),
								 savingsTotalIncome.asObservable()).subscribe {
									(savingsExpense, savingsIncome) in
									self.reloadUI?()
								}.disposed(by: disposeBag)
		
		Observable.combineLatest(
								 wantsTotalIncome.asObservable(),
								 wantsTotalExpense.asObservable()).subscribe {
									(wantsIncom, wantsExpense) in
									self.reloadUI?()
								}.disposed(by: disposeBag)
		
		Observable.combineLatest(
								 needsTotalIncome.asObservable(),
								 needsTotalExpense.asObservable()).subscribe {
									(needsIncome, needsExpense) in
									self.reloadUI?()
								}.disposed(by: disposeBag)
		
	}
	
	private func getUserId() -> String{
		guard let userId = Auth.auth().currentUser?.uid else { return "" }
		return userId
	}
	
	func getUserData() {
		database.collection("users").document(getUserId()).addSnapshotListener({ documentSnapshot, error in
			guard let document = documentSnapshot else {
				print("KAYAYU get data failed")
				return
			}
			
			do {
				guard let userData = try document.data(as: Users.self) else {
					print("KAYAYU failed get userData")
					return
				}
				self.user.accept(userData)
				
			} catch {
				print(error)
			}
		})
	}
	
	//PROGRESS BAR RATIO
	func calculateNeedsProgressBarRatio() -> Float {
		guard let needsBalance = self.needsTotalIncome.value,
			  let needsTotalTrans = self.needsTotalExpense.value,
			  needsBalance > 0, needsTotalTrans > 0 else {
			return 0
		}
		
		return needsTotalTrans/needsBalance
	}
	
	func calculateWantsProgressBarRatio() -> Float {
		guard let wantsBalance = self.wantsTotalIncome.value,
			  let wantsTotalTrans = self.wantsTotalExpense.value,
			  wantsBalance > 0, wantsTotalTrans > 0 else {
			return 0
		}
		
		return wantsTotalTrans/wantsBalance
	}
	
	func calculateSavingsProgressBarRatio() -> Float {
		guard let savingsBalance = self.savingsTotalIncome.value,
			  let savingsTotalTrans = self.savingsTotalExpense.value,
			  savingsBalance >= 0, savingsTotalTrans >= 0 else {
			return 0
		}
		
		return (1 - savingsTotalTrans/savingsBalance)
	}
	
	
	//INCOME
	func getAllIncomeData(startDate: Date, endDate: Date) {
		database.collection("transactions")
			.whereField("user_id", isEqualTo: getUserId())
			.whereField("transaction_date", isGreaterThan: startDate)
			.whereField("transaction_date", isLessThan: endDate)
			.whereField("income_flag", isEqualTo: true)
			.order(by: "transaction_date", descending: true)
			.addSnapshotListener { (documentSnapshot, errorMsg) in
				
				if let errorMsg = errorMsg {
					print("Error get Income Transaction Data \(errorMsg)")
				}
				else {
					var incomeAllCategoryTotal: Float = 0
					for document in documentSnapshot!.documents {
						
						do {
							guard let transData = try document.data(as: Transactions.self) else {
								print("KAYAYU failed get transactionData")
								return
							}
							
							if let transDate = transData.transaction_date,
							   self.calendarHelper.monthInt(date: startDate) == self.calendarHelper.monthInt(date: transDate),
							   let incomeFlag = transData.income_flag, incomeFlag == true,
							   let amount = transData.amount {
								incomeAllCategoryTotal += amount
							}
							
						} catch {
							print(error)
						}
						
					}
					self.allTotalIncome.accept(incomeAllCategoryTotal)
					self.calculateNeedsTotalIncome()
					self.calculateWantsTotalIncome()
					self.calculateSavingsTotalIncome()
				}
			}
	}
	
	private func calculateNeedsTotalIncome() {
		var totalNeeds:Float = 0
		
		if let allIncome = self.allTotalIncome.value  {
			totalNeeds += allIncome * kayayuRatioValue.needs.rawValue
		}
		
		print("Total Needs \(totalNeeds)")
		self.needsTotalIncome.accept(totalNeeds)
	}
	
	private func calculateWantsTotalIncome() {
		var totalWants:Float = 0
		
		if let allIncome = self.allTotalIncome.value  {
			totalWants += allIncome * kayayuRatioValue.wants.rawValue
		}
		
		print("Total Wants \(totalWants)")
		self.wantsTotalIncome.accept(totalWants)
	}
	
	private func calculateSavingsTotalIncome() {
		var totalSavings:Float = 0
		
		if let allIncome = self.allTotalIncome.value  {
			totalSavings += allIncome * kayayuRatioValue.savings.rawValue
		}
		
		print("Total Savings \(totalSavings)")
		self.savingsTotalIncome.accept(totalSavings)
		
	}
	
	//EXPENSE

	private func calculateNeedsTotalExpense() {
		var totalNeeds:Float = 0
		
		if let needsData = self.needsTransactionData.value  {
			for data in needsData {
				if let amount = data.amount,
				   let isIncome = data.income_flag,
				   !isIncome  {
					totalNeeds += amount
				}
			}
		}
		
		self.needsTotalExpense.accept(totalNeeds)
	}
	
	private func calculateWantsTotalExpense() {
		var totalWants:Float = 0
		
		if let wantsData = self.wantsTransactionData.value  {
			for data in wantsData {
				
				if let amount = data.amount,
				   let isIncome = data.income_flag,
				   !isIncome  {
					totalWants += amount
					
				}
			}
		}
		
		self.wantsTotalExpense.accept(totalWants)
	}
	
	private func calculateSavingsTotalExpense() {
		
		var totalSavings:Float = 0
		
		if let savingsData = self.savingsTransactionData.value  {
			for data in savingsData {
				if let amount = data.amount,
				   let isIncome = data.income_flag,
				   !isIncome  {
					totalSavings += amount
				}
			}
		}
		
		self.savingsTotalExpense.accept(totalSavings)
		
	}
	
	
	//GET DATA TRANSACTION
	
	func getPerCategoryTransDataSpecMonth(startDate: Date, endDate: Date) {
		self.getNeedsTransDataSpecMonth(startDate: startDate, endDate: endDate)
		self.getWantsTransDataSpecMonth(startDate: startDate, endDate: endDate)
		self.getSavingsTransDataSpecMonth(startDate: startDate, endDate: endDate)
	}
	
	private func getNeedsTransDataSpecMonth(startDate: Date, endDate: Date) {
		database.collection("transactions")
			.whereField("user_id", isEqualTo: getUserId())
			.whereField("transaction_date", isGreaterThan: startDate)
			.whereField("transaction_date", isLessThan: endDate)
			.whereField("category", isEqualTo: kayayuRatioTitle.needs.rawValue.lowercased())
			.order(by: "transaction_date", descending: true).addSnapshotListener { (documentSnapshot, errorMsg) in
				if let errorMsg = errorMsg {
					print("Error Get Needs Transaction Data \(errorMsg)")
				}
				else {
					var documentArray: [Transactions] = []
					for document in documentSnapshot!.documents {
						
						do {
							guard let trans = try document.data(as: Transactions.self) else {
								print("KAYAYU failed get Needs Transaction Data")
								return
							}
							documentArray.append(trans)
							
						} catch {
							print(error)
						}
						
					}
					self.needsTransactionData.accept(documentArray)
					self.calculateNeedsTotalExpense()
				}
			}
	}
	
	private func getWantsTransDataSpecMonth(startDate: Date, endDate: Date){
		database.collection("transactions")
			.whereField("user_id", isEqualTo: getUserId())
			.whereField("transaction_date", isGreaterThan: startDate)
			.whereField("transaction_date", isLessThan: endDate)
			.whereField("category", isEqualTo: kayayuRatioTitle.wants.rawValue.lowercased())
			.order(by: "transaction_date", descending: true).addSnapshotListener { (documentSnapshot, errorMsg) in
				if let errorMsg = errorMsg {
					print("Error Get Wants Transaction Data \(errorMsg)")
				}
				else {
					var documentArray: [Transactions] = []
					for document in documentSnapshot!.documents {
						
						do {
							guard let trans = try document.data(as: Transactions.self) else {
								print("KAYAYU failed get transactionData")
								return
							}
							documentArray.append(trans)
							
						} catch {
							print(error)
						}
						
					}
					self.wantsTransactionData.accept(documentArray)
					self.calculateWantsTotalExpense()
				}
			}
	}
	
	private func getSavingsTransDataSpecMonth(startDate: Date, endDate: Date) {
		database.collection("transactions")
			.whereField("user_id", isEqualTo: getUserId())
			.whereField("transaction_date", isGreaterThan: startDate)
			.whereField("transaction_date", isLessThan: endDate)
			.whereField("category", isEqualTo: kayayuRatioTitle.savings.rawValue.lowercased())
            .order(by: "transaction_date", descending: true).addSnapshotListener { (documentSnapshot, errorMsg) in
				if let errorMsg = errorMsg {
					print("Error Get Savings Transaction Data \(errorMsg)")
				}
				else {
					var documentArray: [Transactions] = []
					for document in documentSnapshot!.documents {
						
						do {
							guard let trans = try document.data(as: Transactions.self) else {
								print("KAYAYU failed get transactionData")
								return
							}
							documentArray.append(trans)
							
						} catch {
							print(error)
						}
						
					}
					self.savingsTransactionData.accept(documentArray)
					self.calculateSavingsTotalExpense()
				}
			}
	}
	
	
	
}
