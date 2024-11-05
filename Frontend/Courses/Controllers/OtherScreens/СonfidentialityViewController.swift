//
//  СonfidentialityViewController.swift
//  Courses
//
//  Created by Руслан on 30.10.2024.
//

import UIKit

class ConfidentialityViewController: UIViewController {
    
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var oldPassword: UITextField!
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startPosition = errorView.center
        errorView.isHidden = true
        view.addSubview(errorView)
    }
    
    @IBAction func viewPassword(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            oldPassword.isSecureTextEntry = false
            sender.tag = 2
        case 1:
            newPassword.isSecureTextEntry = false
            sender.tag = 3
        case 2:
            oldPassword.isSecureTextEntry = true
            sender.tag = 0
        case 3:
            newPassword.isSecureTextEntry = true
            sender.tag = 1
        default:
            break
        }
    }
    
    private func deleteAccount() {
        Task {
            do {
                try await User().deleteAccount()
                UD().clearUD()
                self.navigationController?.popToRootViewController(animated: true)
            }catch {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: "Попробуйте позже")
            }
        }
    }
    
    private func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Внимание",
                                      message: "Вы действительно хотите удалить свой аккаунт?",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Да", style: .default) { _ in
            self.deleteAccount()
        }
        
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    
        present(alert, animated: true)
    }
    
    @IBAction func changePassword(_ sender: UIButton) {
        errorView.isHidden = false
        errorView.configureUnavailable(title: "Cкоро", description: "В данный момент недоступно")
    }
    
    @IBAction func deleteAccount(_ sender: UIButton) {
        showAccessDeniedAlert()
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }
    
}
