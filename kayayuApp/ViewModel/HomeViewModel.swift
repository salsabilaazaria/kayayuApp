//
//  HomeViewModel.swift
//  kayayuApp
//
//  Created by angie on 04/12/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import RxCocoa
import RxSwift



class HomeViewModel {
	var reloadUI: (() -> Void)?
	
	let database = Firestore.firestore()
    let calendarHelper = CalendarHelper()
	var user: BehaviorRelay<Users?> = BehaviorRelay<Users?>(value: nil)
	var transactionsData: BehaviorRelay<[Transactions]?> = BehaviorRelay<[Transactions]?>(value: nil)
	
	var userBalanceTotal: Float = 0
    
	init() {
		self.getUserData()
		self.getTransactionData()
		self.configureObserver()
	}
	
	private func configureObserver() {
		self.transactionsData.asObservable().subscribe(onNext: { _ in
			self.reloadUI?()
		})
	}
	
	private func getUserId() -> String{
		guard let userId = Auth.auth().currentUser?.uid else { return "" }
		print("KAYAYU USER ID \(userId)")
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
	
	func getTransactionData () {
        database.collection("transactions").whereField("user_id", isEqualTo: getUserId()).whereField("transaction_date", isGreaterThan: calendarHelper.getCurrStartMonth()).whereField("transaction_date", isLessThan: calendarHelper.getCurrEndMonth()).order(by: "transaction_date", descending: true).getDocuments() { (documentSnapshot, errorMsg) in
			if let errorMsg = errorMsg {
				print("Error get Transaction Data \(errorMsg)")
			}
			else {
				var count = 0
				var docummentArray: [Transactions] = []
				for document in documentSnapshot!.documents {
					count += 1
					
					do {
						guard let trans = try document.data(as: Transactions.self) else {
							print("KAYAYU failed get transactionData")
							return
						}
						docummentArray.append(trans)
						
					} catch {
						print(error)
					}
					
				}
				self.transactionsData.accept(docummentArray)
			}
		}
	}
    
    func getTransactionData2 () {
        database.collection("transactions").whereField("user_id", isEqualTo: getUserId()).order(by: "transaction_date", descending: true).getDocuments() { (documentSnapshot, errorMsg) in
            if let errorMsg = errorMsg {
                print("Error get Transaction Data \(errorMsg)")
            }
            else {
                var count = 0
                var docummentArray: [Transactions] = []
                for document in documentSnapshot!.documents {
                    count += 1
                    
                    do {
                        guard let trans = try document.data(as: Transactions.self) else {
                            print("KAYAYU failed get transactionData")
                            return
                        }
                        docummentArray.append(trans)
                        
                    } catch {
                        print(error)
                    }
                    
                }
                self.transactionsData.accept(docummentArray)
            }
        }
    }
	
	func deleteTransactionData(transactionDelete: Transactions) {
		guard var tempTransactionData = self.transactionsData.value,
			  let indexDelete = tempTransactionData.firstIndex(where: { data in
				return data.transaction_id == transactionDelete.transaction_id
			  }) else {
			return
		}
		
		tempTransactionData.remove(at: indexDelete)
		
		self.transactionsData.accept(tempTransactionData)
	}
	
	func calculateIncomePerDay(date: Date) -> Float{
		guard let transactionsData = self.transactionsData.value else {
			return 0
		}
		
		var incomeTotal: Float = 0
		for transData in transactionsData {
			if let incomeFlag = transData.income_flag, incomeFlag == true,
			   let amount = transData.amount,
			   transData.transaction_date == date  {
				
				incomeTotal += amount
			}
		}
		
		return incomeTotal
	}
	
	func calculateExpensePerDay(date: Date) -> Float{
		guard let transactionsData = self.transactionsData.value else {
			return 0
		}
		
		var expenseTotal: Float = 0
		for transData in transactionsData {
			if let incomeFlag = transData.income_flag, incomeFlag == false,
			   let amount = transData.amount,
			   transData.transaction_date == date {
				
				expenseTotal += amount
			}
		}
		
		return expenseTotal
	}
	
}
