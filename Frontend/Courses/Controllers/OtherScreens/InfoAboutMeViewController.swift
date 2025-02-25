//
//  InfoAboutMeViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 06.07.2024.
//

import UIKit

class InfoAboutMeViewController: UIViewController {

    @IBOutlet weak var closeBirthdayBtn: UIButton!
    @IBOutlet weak var closeGoalBtn: UIButton!
    @IBOutlet weak var closeLevelBtn: UIButton!
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
    private var selectBirthday: String? {
        didSet {
            if selectBirthday == nil {
                closeBirthdayBtn.isHidden = true
            }else {
                closeBirthdayBtn.isHidden = false
            }
        }
    }
    private var selectLevel: String? {
        didSet {
            if selectLevel == nil {
                closeLevelBtn.isHidden = true
            }else {
                closeLevelBtn.isHidden = false
            }
        }
    }
    private var selectGoal: String? {
        didSet {
            if selectGoal == nil {
                closeGoalBtn.isHidden = true
            }else {
                closeGoalBtn.isHidden = false
            }
        }
    }
    var picker: Picker?
    var intentionArray = [String]()
    var levelPreparationArray = [String]()
    private var meInfo = User.info

    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        pickerView.delegate = self
        pickerView.dataSource = self
        weightTextField.delegate = self
        heightTextField.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startPosition = mainView.frame.origin
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
        formatter.dateFormat = "yyyy-MM-dd"
        addText(text: formatter.string(from: sender.date), currentLbl: birthdayLbl)
    }


    func datePickerDesign() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        datePicker.setValue(UIColor.grayMain, forKey: "textColor")
        datePicker.maximumDate = Date()
    }

    func design() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        heightTextField.attributedPlaceholder = NSAttributedString(string: "Рост", attributes: [NSAttributedString.Key.foregroundColor: UIColor.grayMain, NSAttributedString.Key.font: font!])
        weightTextField.attributedPlaceholder = NSAttributedString(string: "Вес", attributes: [NSAttributedString.Key.foregroundColor: UIColor.grayMain, NSAttributedString.Key.font: font!])
        intentionArray = [Goal.loseWeight.thirdString(), Goal.gainWeight.thirdString(), Goal.health.thirdString(), Goal.other.thirdString()]
        levelPreparationArray = [Level.beginner.thirdString(), Level.middle.thirdString(), Level.advanced.thirdString(), Level.professional.thirdString()]
        datePickerDesign()
        pickerViewDesign()
        addInfo()
    }

    func pickerViewDesign() {
        pickerView.setValue(UIColor.grayMain, forKey: "textColor")
        viewPV.isHidden = true
    }

    private func addInfo() {
        if let birthday = meInfo.birthday {
            addText(text: birthday, currentLbl: birthdayLbl)
        }
        if let level = meInfo.level {
            addText(text: level.thirdString(), currentLbl: levelPreparationLbl)
        }
        if let goal = meInfo.goal {
            addText(text: goal.thirdString(), currentLbl: intentionLbl)
        }
        if let height = meInfo.height {
            heightTextField.text = "\(height)"
            heightTextField.textColor = UIColor.label
        }
        if let weight = meInfo.weight {
            weightTextField.text = "\(weight)"
            weightTextField.textColor = UIColor.label
        }
    }

    private func openPicker() {
        heightTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        viewPV.isHidden = false
        datePicker.isHidden = true
        pickerView.isHidden = false
        pickerView.reloadAllComponents()
    }

    private func changeUser() {
        meInfo.height = Double(heightTextField.text!)
        meInfo.weight = Double(weightTextField.text!)
        meInfo.birthday = selectBirthday
        if selectGoal != nil {
            meInfo.goal = Goal.thirdGoal(selectGoal!)
        }else {
            meInfo.goal = nil
        }
        if selectLevel != nil {
            meInfo.level = Level.thirdLevel(selectLevel!)
        }else {
            meInfo.level = nil
        }
    }

    private func addText(text:String, currentLbl: UILabel) {
        switch currentLbl {
        case birthdayLbl:
            selectBirthday = text
        case levelPreparationLbl:
            selectLevel = text
        case intentionLbl:
            selectGoal = text
        default:
            break
        }
        currentLbl.textColor = .label
        currentLbl.text = text
    }

    private func clearText(currentLbl:UILabel) {
        switch currentLbl {
        case birthdayLbl:
            birthdayLbl.text = "Дата Рождения"
            selectBirthday = nil
        case levelPreparationLbl:
            levelPreparationLbl.text = "Уровень подготовки"
            selectLevel = nil
        case intentionLbl:
            intentionLbl.text = "Цель"
            selectGoal = nil
        default:
            break
        }
        currentLbl.textColor = UIColor.forTextFields
    }


    @IBAction func clearInfo(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            clearText(currentLbl: birthdayLbl)
        case 1:
            clearText(currentLbl: levelPreparationLbl)
        case 2:
            clearText(currentLbl: intentionLbl)
        default:
            break
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
                    self.mainView.frame.origin = self.startPosition
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
        Task {
            changeUser()
            try await User().changeInfoAboutMe(id: meInfo.id,user: meInfo)
            dismiss(animated: false)
        }
    }

    @IBAction func dissmis(_ sender: UIButton) {
        dismiss(animated: false)
    }

    @IBAction func birthday(_ sender: UIButton) {
        heightTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        picker = .birthday
        viewPV.isHidden = false
        datePicker.isHidden = false
        pickerView.isHidden = true
    }

    @IBAction func levelPreparation(_ sender: UIButton) {
        pickerView.selectRow(0, inComponent: 0, animated: false)
        addText(text: levelPreparationArray[0], currentLbl: levelPreparationLbl)
        picker = .levelPreparation
        openPicker()
    }

    @IBAction func intention(_ sender: UIButton) {
        pickerView.selectRow(0, inComponent: 0, animated: false)
        addText(text: intentionArray[0], currentLbl: intentionLbl)
        picker = .intention
        openPicker()
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
            addText(text: levelPreparationArray[row], currentLbl: levelPreparationLbl)
        }else {
            addText(text: intentionArray[row], currentLbl: intentionLbl)
        }
    }

}
extension InfoAboutMeViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text == "" {
            textField.textColor = UIColor.forTextFields
        }else {
            textField.textColor = UIColor.label
        }
    }
}
