//
//  PickerModelViewController.swift
//  Courses
//
//  Created by Руслан on 29.08.2024.
//

import UIKit

class PickerModelViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: AddCategoryDelegate?
    var category = [Category]()
    var selectCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        getCategories()
        design()
    }
    
    private func design() {
        pickerView.setValue(UIColor.white, forKey: "textColor")
        
    }
    
    private func getCategories() {
        Task {
            category = try await Categories().getCategories()
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
