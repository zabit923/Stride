//
//  WithdradSBPViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 16.09.2024.
//

import UIKit

class WithdrawSBPViewController: UIViewController {
    
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var moneyCount: UILabel!
    @IBOutlet weak var banksTableView: UITableView!
    @IBOutlet weak var numberTextField: UITextField!
    
    var money = 0
    var arrayBanks = [Banks]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBank()
        design()
        numberTextField.delegate = self
        banksTableView.delegate = self
        banksTableView.dataSource = self
    }
    
    private func design() {
        banksTableView.isHidden = true
        moneyCount.text = "\(money)"
    }
    
    private func addBank() {
        arrayBanks = [Banks(name: "Сбербанк", image: ""), Banks(name: "Т-Банк", image: ""), Banks(name: "АльфаБанк", image: ""), Banks(name: "ГазПромБанк", image: "")]
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        numberTextField.resignFirstResponder()
        banksTableView.isHidden = true
    }
    
    @IBAction func fluent(_ sender: UIButton) {
        
    }
    
    @IBAction func banksTV(_ sender: UIButton) {
        if banksTableView.isHidden == true {
            banksTableView.isHidden = false
        }else {
            banksTableView.isHidden = true
        }
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
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return ValidateTF().phone(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
}
