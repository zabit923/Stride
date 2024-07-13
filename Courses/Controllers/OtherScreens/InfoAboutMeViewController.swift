//
//  InfoAboutMeViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 06.07.2024.
//

import UIKit

class InfoAboutMeViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewPV: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var birthdayLbl: UILabel!
    @IBOutlet weak var levelPreparationLbl: UILabel!
    @IBOutlet weak var intentionLbl: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    private var startPosition = CGPoint()
    
    var picker: Picker?
    var intentionArray = [String]()
    var levelPreparationArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        startPosition = mainView.center
        pickerView.delegate = self
        pickerView.dataSource = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillAppear(notification: Notification) {
        bottomConstraint.constant = 50
    }

    @objc func keyboardWillDisappear() {
        bottomConstraint.constant = 0
    }
    
    @objc func datePickerValueChanged (sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        birthdayLbl.text = formatter.string(from: sender.date)
    }
    

    func datePickerDesign() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        birthdayLbl.text = formatter.string (from: date)
        birthdayLbl.textColor = .white
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.maximumDate = Date()
    }
    
    func design() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        heightTextField.attributedPlaceholder = NSAttributedString(string: "Рост", attributes: [NSAttributedString.Key.foregroundColor: UIColor.forTextFields, NSAttributedString.Key.font: font!])
        weightTextField.attributedPlaceholder = NSAttributedString(string: "Вес", attributes: [NSAttributedString.Key.foregroundColor: UIColor.forTextFields, NSAttributedString.Key.font: font!])
        intentionArray = ["Похудеть", "Набрать мышечную массу", "Сбросить вес", "Подсушиться"]
        levelPreparationArray = ["Плохой", "Средний", "Хороший"]
        pickerViewDesign()
        datePickerDesign()
    }
    
    func pickerViewDesign() {
        pickerView.setValue(UIColor.white, forKey: "textColor")
        viewPV.isHidden = true
        if UD().getBirthday() != "" {
            birthdayLbl.text = UD().getBirthday()
        }else if UD().getLevelPreparation() != "" {
            levelPreparationLbl.text = UD().getLevelPreparation()
        }else if UD().getIntention() != "" {
            intentionLbl.text = UD().getIntention()
        }
    }

    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: mainView)
        switch sender.state {
        case .changed:
            guard translation.y > 0 else { return }
            mainView.center = CGPoint(x: mainView.center.x, y: mainView.center.y +  translation.y)
            sender.setTranslation(CGPoint.zero, in: mainView)
        case .ended:
            if sender.velocity(in: mainView).y > 500 {
                dismiss(animated: false)
            }else {
                UIView.animate(withDuration: 0.5) {
                    self.mainView.center = self.startPosition
                }
            }
        default:
            break
        }
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        viewPV.isHidden = true
        heightTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
    }
    
    
    @IBAction func ready(_ sender: UIButton) {
        viewPV.isHidden = true
    }
    
    @IBAction func save(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func dissmis(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func birthday(_ sender: UIButton) {
        picker = .birthday
        viewPV.isHidden = false
        datePicker.isHidden = false
        pickerView.isHidden = true
    }
    
    @IBAction func levelPreparation(_ sender: UIButton) {
        pickerView.selectRow(0, inComponent: 0, animated: false)
        levelPreparationLbl.text = levelPreparationArray[0]
        levelPreparationLbl.textColor = .white
        picker = .levelPreparation
        viewPV.isHidden = false
        datePicker.isHidden = true
        pickerView.isHidden = false
        pickerView.reloadAllComponents()
    }
    
    @IBAction func intention(_ sender: UIButton) {
        pickerView.selectRow(0, inComponent: 0, animated: false)
        intentionLbl.text = intentionArray[0]
        intentionLbl.textColor = .white
        picker = .intention
        viewPV.isHidden = false
        datePicker.isHidden = true
        pickerView.isHidden = false
        pickerView.reloadAllComponents()
    }
    
}

extension InfoAboutMeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if picker == .levelPreparation {
            return levelPreparationArray.count
        }else {
            return intentionArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if picker == .levelPreparation {
            return levelPreparationArray[row]
        }else {
            return intentionArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if picker == .levelPreparation {
            levelPreparationLbl.text = levelPreparationArray[row]
            UD().saveLevelPraparation(levelPreparationLbl.text!)
            levelPreparationLbl.textColor = .white
        }else {
            intentionLbl.text = intentionArray[row]
            UD().saveIntention(intentionLbl.text!)
            intentionLbl.textColor = .white
        }
    }
    
}
