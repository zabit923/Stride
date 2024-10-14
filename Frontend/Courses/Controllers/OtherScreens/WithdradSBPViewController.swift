//
//  WithdradSBPViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 16.09.2024.
//

import UIKit

class WithdrawSBPViewController: UIViewController {
    
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var withdrawTextField: UITextField!
    @IBOutlet weak var withdrawBorder: Border!
    @IBOutlet weak var bankBorder: Border!
    @IBOutlet weak var numberBorder: Border!
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var moneyCount: UILabel!
    @IBOutlet weak var banksTableView: UITableView!
    @IBOutlet weak var numberTextField: UITextField!
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    var startPosition = CGPoint()
    var money = 0
    var arrayBanks = [Banks]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearError()
        addBank()
        design()
        textFieldDesign()
        numberTextField.delegate = self
        banksTableView.delegate = self
        banksTableView.dataSource = self
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
    }
    
    private func textFieldDesign() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        withdrawTextField.attributedPlaceholder = NSAttributedString(string: "от 100₽ до 50000₽", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font!])
    }
    
    private func design() {
        banksTableView.isHidden = true
        moneyCount.text = "\(money)"
    }
    
    private func addBank() {
        arrayBanks = [Banks(name: "Сбербанк", image: ""), Banks(name: "Т-Банк", image: ""), Banks(name: "АльфаБанк", image: ""), Banks(name: "ГазПромБанк", image: "")]
    }
    
    
    func clearError() {
        withdrawBorder.color = .lightBlackMain
        numberBorder.color = .lightBlackMain
        bankBorder.color = .lightBlackMain
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
        guard numberTextField.text!.isEmpty == false else {
            numberBorder.color = .errorRed
            throw ErrorNetwork.notFound }
        guard numberTextField.text!.count == 17 else {
            numberBorder.color = .errorRed
            addError(error: "Неправильный номер")
            throw ErrorNetwork.notFound }
        if bankLabel.text == "Выберите ваш банк" {
            bankBorder.color = .errorRed
            addError(error: "Выберите банк")
            throw ErrorNetwork.notFound }
        guard withdrawTextField.text!.isEmpty == false else {
            withdrawBorder.color = .errorRed
            throw ErrorNetwork.notFound }
        guard Int(withdrawTextField.text!)! >= 100 && Int(withdrawTextField.text!)! <= 50000 else {
            withdrawBorder.color = .errorRed
            addError(error: "Вывод средств от 1₽ до 50000₽")
            throw ErrorNetwork.notFound }
        
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        numberTextField.resignFirstResponder()
        withdrawTextField.resignFirstResponder()
    }
    
    
    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }
    
    @IBAction func fluent(_ sender: UIButton) {
       
        finishBtn.isEnabled = false
        Task {
            do {
                clearError()
                try checkInfo()
                guard let money = Int(withdrawTextField.text ?? "0") else { return }
                let sbp: PaymentMethod = .sbp(phoneNumber: numberTextField.text!, amount: money, bank: bankLabel.text!)
                try await Payment().fetchFunds(payment: sbp)
                finishBtn.isEnabled = true
                let result = Int(moneyCount.text!)! - money
                moneyCount.text = "\(result)"
                addSuccess()
            }catch ErrorNetwork.runtimeError(let error) {
                addError(error: error)
                finishBtn.isEnabled = true
            }catch {
                finishBtn.isEnabled = true
            }
        }
    }
    
    @IBAction func banksTV(_ sender: UIButton) {
        banksTableView.isHidden.toggle()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}




extension WithdrawSBPViewController: UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayBanks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = banksTableView.dequeueReusableCell(withIdentifier: "bankTF", for: indexPath) as! BanksTableViewCell
        cell.name.text = arrayBanks[indexPath.row].name
        cell.im.image = UIImage(named: "\(arrayBanks[indexPath.row].image)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bankLabel.text = arrayBanks[indexPath.row].name
        banksTableView.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return ValidateTF().phone(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
}
