//
//  AdminOtherViewController.swift
//  Courses
//
//  Created by Руслан on 28.10.2024.
//

import UIKit

class AdminOtherViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var payments = [Payments]()
    var selectPayments: Payments!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPayments()
    }
    
    func getPayments() {
        Task {
            let results = try await Admin().requestPayments()
            payments += results
            tableView.reloadData()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
extension AdminOtherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingsTableViewCell
        if payments[indexPath.row].paymentsInfo.phoneNumber == nil {
            cell.lbl.text = payments[indexPath.row].paymentsInfo.cardNumber
        }else {
            cell.lbl.text = payments[indexPath.row].paymentsInfo.phoneNumber
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectPayments = payments[indexPath.row]
        performSegue(withIdentifier: "money", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "money" {
            let vc = segue.destination as! AdminMoneyInfoViewController
            vc.payments = selectPayments
        }
        
    }
    
    
    
    
}
