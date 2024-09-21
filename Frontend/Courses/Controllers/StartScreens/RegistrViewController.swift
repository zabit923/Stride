//
//  RegistrViewController.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import UIKit
import Lottie

class RegistrViewController: UIViewController {

    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var phoneBorder: Border!
    @IBOutlet weak var passwordAgoBorder: Border!
    @IBOutlet weak var passwordBorder: Border!
    @IBOutlet weak var mailBorder: Border!
    @IBOutlet weak var surnameBorder: Border!
    @IBOutlet weak var nameBorder: Border!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var passwordAgo: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var mail: UITextField!

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    var startPosition = CGPoint()

    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber.delegate = self
        name.delegate = self
        lastName.delegate = self
        name.autocapitalizationType = .words
        lastName.autocapitalizationType = .words
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
    }

    func clearError() {
        nameBorder.color = UIColor.lightBlackMain
        surnameBorder.color = UIColor.lightBlackMain
        mailBorder.color = UIColor.lightBlackMain
        passwordBorder.color = UIColor.lightBlackMain
        passwordAgoBorder.color = UIColor.lightBlackMain
        phoneBorder.color = UIColor.lightBlackMain
        errorView.isHidden = true
    }

    func addError(error: String) {
        errorView.isHidden = false
        errorView.configure(title: "Ошибка", description: error)
    }
    
    private func loadingStart() {
        loading.play()
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = false
        registerBtn.isHidden = true
    }

    private func loadingStop() {
        loading.stop()
        loading.isHidden = true
        registerBtn.isHidden = false
    }

    func checkInfo() throws {
        guard password.text == passwordAgo.text else {
            passwordBorder.color = .errorRed
            passwordAgoBorder.color = .errorRed
            errorView.configure(title: "Неверный пароль", description: "Пароли не совпадают")
            errorView.isHidden = false
            throw ErrorNetwork.notFound }
        guard name.text!.isEmpty == false else {
            nameBorder.color = .errorRed
            throw ErrorNetwork.notFound }
        guard lastName.text!.isEmpty == false else {
            surnameBorder.color = .errorRed
            throw ErrorNetwork.notFound }
        guard mail.text!.isEmpty == false else {
            mailBorder.color = .errorRed
            throw ErrorNetwork.notFound }
        guard password.text!.isEmpty == false else {
            passwordBorder.color = .errorRed
            throw ErrorNetwork.notFound }
    }

    @IBAction func registr(_ sender: UIButton) {
        loadingStop()
        registerBtn.isEnabled = false
        Task {
            do {
                clearError()
                try checkInfo()
                let phoneNumberFormat = phoneNumber.text!.format(with: "+XXXXXXXXXXX")
                try await Sign().registr(phoneNumber: phoneNumberFormat, password: password.text!, name: name.text!, lastName: lastName.text!, mail: mail.text!)
                registerBtn.isEnabled = true
                loadingStop()
                performSegue(withIdentifier: "success", sender: self)
            }catch ErrorNetwork.runtimeError(let error) {
                addError(error: error)
                registerBtn.isEnabled = true
                loadingStop()
            } catch {
                loadingStop()
                registerBtn.isEnabled = true
            }
        }
    }


    @IBAction func passwordHidden(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            password.isSecureTextEntry = false
            sender.tag = 2
        case 1:
            passwordAgo.isSecureTextEntry = false
            sender.tag = 3
        case 2:
            password.isSecureTextEntry = true
            sender.tag = 0
        case 3:
            passwordAgo.isSecureTextEntry = true
            sender.tag = 1
        default:
            break
        }
    }


    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        phoneNumber.resignFirstResponder()
        password.resignFirstResponder()
        passwordAgo.resignFirstResponder()
        lastName.resignFirstResponder()
        name.resignFirstResponder()
        mail.resignFirstResponder()
    }

}
extension RegistrViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumber {
            return ValidateTF().phone(textField, shouldChangeCharactersIn: range, replacementString: string)
        }else {
            return ValidateTF().nameAndSurname(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
    }

}
