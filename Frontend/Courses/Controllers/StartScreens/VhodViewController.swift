//
//  VhodViewController.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import UIKit
import Lottie

class VhodViewController: UIViewController {

    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var passwordBorder: Border!
    @IBOutlet weak var phoneBorder: Border!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    var startPosition = CGPoint()


    override func viewDidLoad() {
        super.viewDidLoad()
        phone.delegate = self
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
    }

    func clearError() {
        passwordBorder.color = .lightBlackMain
        phoneBorder.color = .lightBlackMain
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
        nextBtn.isHidden = true
    }

    private func loadingStop() {
        loading.stop()
        loading.isHidden = true
        nextBtn.isHidden = false
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
        loadingStart()
        nextBtn.isEnabled = false
        Task {
            do {
                clearError()
                try checkInfo()
                let phoneNumberFormat = phone.text!.format(with: "+XXXXXXXXXXX")
                try await Sign().vhod(phoneNumber: phoneNumberFormat, password: password.text!)
                nextBtn.isEnabled = true
                loadingStop()
                performSegue(withIdentifier: "success", sender: self)
            }catch ErrorNetwork.runtimeError(let error) {
                addError(error: error)
                nextBtn.isEnabled = true
                loadingStop()
            }catch {
                loadingStop()
            }
        }
    }


    @IBAction func apple(_ sender: UIButton) {

    }

    @IBAction func google(_ sender: UIButton) {
        Sign().signGoogle(self)
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
        errorView.swipe(sender: sender, startPosition: startPosition)
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        password.resignFirstResponder()
        phone.resignFirstResponder()
    }
}

extension VhodViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return ValidateTF().phone(textField, shouldChangeCharactersIn: range, replacementString: string)
    }


}
