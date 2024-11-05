//
//  AdminMoneyInfoViewController.swift
//  Courses
//
//  Created by Руслан on 29.10.2024.
//

import UIKit

class AdminMoneyInfoViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberSBP: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var moneyCount: UILabel!
    @IBOutlet weak var bankSBP: UILabel!
    @IBOutlet weak var card: UILabel!
    
    var payments: Payments!
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
        design()
    }
    
    private func design() {
        moneyCount.text = "\(payments.paymentsInfo.amount) рублей"
        bankSBP.text = payments.paymentsInfo.bank ?? ""
        card.text = payments.paymentsInfo.cardNumber ?? ""
        phoneNumberSBP.text = payments.paymentsInfo.phoneNumber ?? ""
    }
    
    
    @IBAction func success(_ sender: UIButton) {
        Task {
            do {
                try await Admin().completedPayments(id: payments.paymentID)
                navigationController?.popViewController(animated: true)
            }catch {
                errorView.configure(title: "Ошибка", description: "Попробуйте позже")
                errorView.isHidden = false
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }
    
}
