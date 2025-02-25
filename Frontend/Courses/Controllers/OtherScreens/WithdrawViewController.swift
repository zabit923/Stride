//
//  WithdrawViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 12.09.2024.
//

import UIKit

class WithdrawViewController: UIViewController {

    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var withdrawBorder: Border!
    @IBOutlet weak var cardBorder: Border!
    @IBOutlet weak var moneyCount: UILabel!
    @IBOutlet weak var withdrawTextField: UITextField!
    @IBOutlet weak var cardTextField: UITextField!
    
    var money = 0
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 40, height: 70))
    var startPosition = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearError()
        textFieldDesign()
        cardTextField.delegate = self
        moneyCount.text = "\(money)"
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
    }

    private func textFieldDesign() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        withdrawTextField.attributedPlaceholder = NSAttributedString(string: "от 100₽ до 50000₽", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font!])
        cardTextField.attributedPlaceholder = NSAttributedString(string: "**** **** **** ****", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font!])
    }
    
    func clearError() {
        withdrawBorder.color = .lightBlackMain
        cardBorder.color = .lightBlackMain
        errorView.isHidden = true
    }
    
    func addSuccess() {
        errorView.isHidden = false
        errorView.configureSuccess(title: "Успешно", description: "Средства будут выведены в течении 48 часов")
    }
    
    func addError(error: String) {
        errorView.isHidden = false
        errorView.configure(title: "Ошибка", description: error)
    }
    
    private func checkInfo() throws {
        guard cardTextField.text!.isEmpty == false else {
            cardBorder.color = .errorRed
            throw ErrorNetwork.notFound }
        guard cardTextField.text!.count == 19 else {
            cardBorder.color = .errorRed
            addError(error: "Неправильный формат банковской карты")
            throw ErrorNetwork.notFound }
        guard withdrawTextField.text!.isEmpty == false else {
            withdrawBorder.color = .errorRed
            throw ErrorNetwork.notFound }
        guard Int(withdrawTextField.text!)! >= 100 && Int(withdrawTextField.text!)! <= 50000 else {
            withdrawBorder.color = .errorRed
            addError(error: "Вывод средств от 100₽ до 50000₽")
            throw ErrorNetwork.notFound }
        
    }

    @IBAction func sbp(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSBP", sender: self)
    }
    
    @IBAction func fluent(_ sender: UIButton) {
        finishBtn.isEnabled = false
        Task {
            do {
                clearError()
                try checkInfo()
                guard let moneyFluent = Int(withdrawTextField.text ?? "0") else { return }
                let cardFormat = cardTextField.text!.format(with: "XXXX XXXX XXXX XXXX")
                let card: PaymentMethod = .card(cardNumber: cardFormat, amount: moneyFluent)
                try await Payment().fetchFunds(payment: card)
                finishBtn.isEnabled = true
                let result = Int(moneyCount.text!)! - moneyFluent
                money = result
                moneyCount.text = "\(money)"
                addSuccess()
            }catch ErrorNetwork.runtimeError(let error) {
                addError(error: error)
                finishBtn.isEnabled = true
            }catch {
                finishBtn.isEnabled = true
            }
        }
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        withdrawTextField.resignFirstResponder()
        cardTextField.resignFirstResponder()
    }
    
    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
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
