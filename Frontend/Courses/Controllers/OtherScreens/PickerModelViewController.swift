//
//  PickerModelViewController.swift
//  Courses
//
//  Created by Руслан on 29.08.2024.
//

import UIKit

class PickerModelViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var promoTableView: UITableView!
    
    var delegate: AddCategoryDelegate?
    var category = [Category]()
    var promocodes = [Promocodes]()
    var selectCategory: Category?
    var isCategory = true

    override func viewDidLoad() {
        super.viewDidLoad()
        promoTableView.delegate = self
        promoTableView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        design()
    }

    private func design() {
        pickerView.setValue(UIColor.label, forKey: "textColor")
        if isCategory {
            getCategories()
            pickerView.isHidden = false
            promoTableView.isHidden = true
        }else {
            getMyPromocodes()
            pickerView.isHidden = true
            promoTableView.isHidden = false
        }
    }
    
    private func getMyPromocodes() {
        Task {
            promocodes = try await Promocodes().getMyPromocodes()
            promoTableView.reloadData()
        }
    }

    private func getCategories() {
        Task {
            category = try await Category.getCategories()
            guard category.isEmpty == false else { return }
            selectCategory = category[0]
            pickerView.reloadAllComponents()
        }
    }

    @IBAction func back(_ sender: UIButton) {
        if let res = selectCategory {
            delegate?.category(category: res)
        }
        dismiss(animated: true)
    }

}
extension PickerModelViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row].nameCategory
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.category(category: category[row])
        selectCategory = category[row]
    }
    
}
extension PickerModelViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        promocodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "promo", for: indexPath) as! PromoTableViewCell
        cell.name.text = promocodes[indexPath.row].name
        return cell
    }
    
}
