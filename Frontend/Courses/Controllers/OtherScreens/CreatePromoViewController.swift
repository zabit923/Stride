//
//  CreatePromoViewController.swift
//  Courses
//
//  Created by Руслан on 25.11.2024.
//

import UIKit

class CreatePromoViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var promoNameView: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var dateEndLbl: UILabel!
    @IBOutlet weak var dateStartLbl: UILabel!
    @IBOutlet weak var procentCollectionView: UICollectionView!
    @IBOutlet weak var namePromo: UITextField!
    @IBOutlet weak var titleMain: UILabel!
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    private var procents = [Int]()
    private var selectProcent: Int? = nil
    private var currentLbl: UILabel? = nil
    private var dateStart: String? = nil {
        didSet {
            if dateStart == nil {
                dateStartLbl.text = "Начало"
            }else {
                dateStartLbl.text = dateStart
                
            }
        }
    }
    private var dateEnd: String? = nil {
        didSet {
            if dateEnd == nil {
                dateEndLbl.text = "Конец"
            }else {
                dateEndLbl.text = dateEnd
                
            }
        }
    }
    
    var promoCode: Promocodes? = nil
    weak var delegate: PromoCodeDelegate?
    
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        namePromo.delegate = self
        procentCollectionView.delegate = self
        procentCollectionView.dataSource = self
        design()
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
        bottomConstraint.constant = 100
    }

    @objc func keyboardWillDisappear() {
        bottomConstraint.constant = 0
    }
    
    private func design() {
        view.addSubview(errorView)
        errorView.isHidden = true
        settingsDatePicker()
        getProcents()
        
        if promoCode == nil {
            titleMain.text = "Создать промокод"
            deleteBtn.isHidden = true
            promoNameView.isHidden = false
            createBtn.setTitle("Создать", for: .normal)
        }else {
            titleMain.text = "Изменить промокод"
            createBtn.setTitle("Изменить", for: .normal)
            deleteBtn.isHidden = false
            promoNameView.isHidden = true
            namePromo.text = promoCode!.name
            selectProcent = getProcentByArray(procent: promoCode!.procent)
            dateStart = promoCode!.dateStart
            dateEnd = promoCode!.dateEnd
        }
    }
    
    private func getProcentByArray(procent: Int) -> Int? {
        for x in 0...procents.count - 1 {
            if procents[x] == procent {
                return x
            }
        }
        return nil
    }
    
    @objc func datePickerValueChanged (sender: UIDatePicker) {
        addText(text: formatter.string(from: sender.date), currentLbl: currentLbl)
    }

    private func addText(text:String, currentLbl: UILabel?) {
        guard let currentLbl = currentLbl else { return }
        switch currentLbl {
        case dateStartLbl:
            dateStart = text
        case dateEndLbl:
            dateEnd = text
        default:
            break
        }
    }

    func settingsDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        datePicker.setValue(UIColor.grayMain, forKey: "textColor")
        datePicker.minimumDate = Date()
    }
    
    private func getProcents() {
        procents += [5,10,15,20,25,30]
    }
    
    private func checkError() -> Bool {
        var results = true
        if namePromo.text == "" {
            results = false
            errorView.configure(title: "Ошибка", description: "Впишите название промокода")
            errorView.isHidden = false
        }
        if selectProcent == nil {
            results = false
            errorView.configure(title: "Ошибка", description: "Выберите процент")
            errorView.isHidden = false
        }
        return results
    }
    
    private func createPromocode() -> Promocodes {
        let promocodes = Promocodes()
        promocodes.name = namePromo.text!
        promocodes.procent = procents[selectProcent!]
        promocodes.dateStart = dateStart
        promocodes.dateEnd = dateEnd
        return promocodes
    }
    
    
    @IBAction func openDatePicker(_ sender: UIButton) {
        viewPicker.isHidden = false
        if sender.tag == 0 {
            currentLbl = dateEndLbl
        }else {
            currentLbl = dateStartLbl
        }
        addText(text: formatter.string(from: Date()), currentLbl: currentLbl)
    }
    
    @IBAction func datePickerClose(_ sender: UIButton) {
        viewPicker.isHidden = true
    }
    
    @IBAction func create(_ sender: UIButton) {
        guard checkError() else { return }
        let promocode = createPromocode()
        Task {
            do {
                if promoCode == nil {
                    let promocode = try await Promocodes().createPromocode(promocode)
                    delegate?.create(promoCode: promocode)
                }else {
                    let promocode = try await Promocodes().changePromocode(promocode)
                    delegate?.change(promoCode: promocode)
                }
                dismiss(animated: false)
            }catch ErrorNetwork.runtimeError(var error) {
                errorView.configure(title: "Ошибка", description: error)
                errorView.isHidden = false
            }catch {
                errorView.configure(title: "Неизвестная ошибка", description: "Попробуйте позже")
                errorView.isHidden = false
            }
        }
    }
    
    @IBAction func deletePromo(_ sender: UIButton) {
        Task {
            do {
                guard let promoCode = promoCode else { return }
                try await Promocodes().deletePromocode(promoCode)
                delegate?.delete(promoCode: promoCode)
                dismiss(animated: false)
            }catch ErrorNetwork.runtimeError(var error) {
                errorView.configure(title: "Ошибка", description: error)
                errorView.isHidden = false
            }catch {
                errorView.configure(title: "Неизвестная ошибка", description: "Попробуйте позже")
                errorView.isHidden = false
            }
        }
    }
    
    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
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
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        namePromo.resignFirstResponder()
        viewPicker.isHidden = true
    }
    
    
}
extension CreatePromoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        procents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "procents", for: indexPath) as! PromoCollectionViewCell
        if selectProcent == indexPath.row {
            cell.backgroundColor = UIColor.blackMain
        }else {
            cell.backgroundColor = .clear
        }
        cell.procent.text = "\(procents[indexPath.row])%"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectProcent = indexPath.row
        procentCollectionView.reloadData()
    }
    
    
    
}
extension CreatePromoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let characterSet = CharacterSet(charactersIn: string.uppercased())
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.text = textField.text?.uppercased()
    }
    
}
