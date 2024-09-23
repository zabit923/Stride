//
//  WithdrawViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 12.09.2024.
//

import UIKit

class WithdrawViewController: UIViewController {

    @IBOutlet weak var moneyCount: UILabel!
    @IBOutlet weak var withdrawTextField: UITextField!
    @IBOutlet weak var cardTextField: UITextField!
    
    var money = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldDesign()
        cardTextField.delegate = self
        moneyCount.text = "\(money)"
    }
    
    private func textFieldDesign() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        withdrawTextField.attributedPlaceholder = NSAttributedString(string: "от 100₽ до 50000₽", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font!])
        cardTextField.attributedPlaceholder = NSAttributedString(string: "**** **** **** ****", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font!])
    }

    @IBAction func sbp(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSBP", sender: self)
    }
    
    @IBAction func fluent(_ sender: UIButton) {
        Task {
            do {
                guard let money = Int(withdrawTextField.text ?? "0") else { return }
                let card: PaymentMethod = .card(cardNumber: cardTextField.text ?? "", amount: money)
                try await Payment().fetchFunds(payment: card)
                let result = Int(moneyCount.text!)! - money
                moneyCount.text = "\(result)"
            }catch ErrorNetwork.runtimeError(let error) {
                print(error)
            }
        }
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        withdrawTextField.resignFirstResponder()
        cardTextField.resignFirstResponder()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToSBP" {
            let vc = segue.destination as! WithdrawSBPViewController
            vc.money = money
        }
        
    }
}

extension WithdrawViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = cardTextField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 19 {
            return false
        }
        
        let digitsOnly = updatedText.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        cardTextField.text = formatCardNumber(digitsOnly)

        return false
    }
    func formatCardNumber(_ number: String) -> String {
        var formattedNumber = ""
        for (index, character) in number.enumerated() {
            if index > 0 && index % 4 == 0 {
                formattedNumber.append(" ")
            }
                formattedNumber.append(character)
        }
        return formattedNumber
    }
}
