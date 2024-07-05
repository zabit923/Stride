//
//  VhodViewController.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import UIKit

class VhodViewController: UIViewController {
    
    @IBOutlet weak var passwordBorder: Border!
    @IBOutlet weak var phoneBorder: Border!
    @IBOutlet weak var errorDescription: UILabel!
    @IBOutlet weak var errorMainText: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var startPosition = CGPoint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phone.delegate = self
        startPosition = errorView.center
    }
    
    func clearError() {
        passwordBorder.color = .lightBlackMain
        phoneBorder.color = .lightBlackMain
        ErrorsView().delete(errorView)
    }
    
    func addError(error: ErrorNetwork) {
        if error == .invalidPassword || error == .invalidLogin {
            ErrorsView().create(descriptionText: "Неправильный логин или пароль", mainText: "Ошибка", errorView, errorDescription, errorMainText)
        }
        if error == .tryAgainLater {
            ErrorsView().create(descriptionText: error.rawValue, mainText: "Неизвестная ошибка", errorView, errorDescription, errorMainText)
        }
    }
    
    func checkInfo() throws {
        guard phone.text!.count > 2 else {
            phoneBorder.color = .errorRed
            throw ErrorNetwork.notFound }
        guard password.text!.isEmpty == false else {
            passwordBorder.color = .errorRed
            throw ErrorNetwork.notFound }
    }
    
    @IBAction func vhod(_ sender: UIButton) {
        Task {
            do {
                clearError()
                try checkInfo()
                let phoneNumberFormat = phone.text!.format(with: "+XXXXXXXXXXX")
                try await Sign().vhod(phoneNumber: phoneNumberFormat, password: password.text!)
                performSegue(withIdentifier: "success", sender: self)
            }catch let error as ErrorNetwork {
                addError(error: error)
            }
        }
    }
    
    
    @IBAction func apple(_ sender: UIButton) {
        
    }
    
    @IBAction func google(_ sender: UIButton) {
        
    }
    
    @IBAction func passwordHidden(_ sender: UIButton) {
        if sender.tag == 0 {
            password.isSecureTextEntry = false
            sender.tag = 1
        }else {
            password.isSecureTextEntry = true
            sender.tag = 0
        }
    }
    
    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: errorView)
        switch sender.state {
        case .changed:
            errorView.center = CGPoint(x: errorView.center.x, y: errorView.center.y +  translation.y)
            sender.setTranslation(CGPoint.zero, in: errorView)
        case .ended:
            if errorView.center.y <= 40 {
                self.errorView.isHidden = true
            }
            UIView.animate(withDuration: 0.5) {
                self.errorView.center = self.startPosition
            }
        default:
            break
        }
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        password.resignFirstResponder()
        phone.resignFirstResponder()
    }
}

extension VhodViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        if newString.format(with: "+X (XXX) XXX-XXXX").count >= 2 {
            textField.text = newString.format(with: "+X (XXX) XXX-XXXX")
            return false
        } else {
            return false
        }
    }

    
}
