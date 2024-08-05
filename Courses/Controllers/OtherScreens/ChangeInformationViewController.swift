//
//  ChangeInformationViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 05.07.2024.
//

import UIKit

class ChangeInformationViewController: UIViewController {
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var surname: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var avatar: UIImageView!
    
    private var avatarImage = UIImage.defaultLogo
    private var avatarURL: String?
    private var activateTF: UITextField?
    private var user = User.info
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber.delegate = self
        descriptionTF.delegate = self
        mail.delegate = self
        design()
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
        guard let activateTF = activateTF else {return}
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let textFieldRect = activateTF.convert(activateTF.bounds, to: scrollView)
            let textFieldBottom = textFieldRect.maxY
            
            let scrollY = textFieldBottom - keyboardHeight
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollY), animated: true)
            self.activateTF = nil
        }
    }

    @objc func keyboardWillDisappear() {
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x,
                                            y: 0), animated: true)
    }
    
    private func design() {
        if user.role == .user {
            descriptionView.isHidden = true
        }else {
            descriptionView.isHidden = false
        }
        addText()
    }
    
    
    private func addText() {
        avatar.image = avatarImage
        name.text = user.name
        surname.text = user.surname
        mail.text = user.email
        phoneNumber.text = user.phone.format(with: "+X (XXX) XXX-XXXX")
        descriptionTF.text = user.coach.description
    }
    
    private func changeUserInfo() {
        user.name = name.text ?? user.name
        user.surname = surname.text ?? user.surname
        user.phone = phoneNumber.text ?? user.phone
        user.email = mail.text ?? user.email
        user.coach.description = descriptionTF.text ?? user.coach.description
        user.avatar = avatarURL ?? user.avatar
    }
    
    @IBAction func save(_ sender: UIButton) {
        Task{
            changeUserInfo()
            try await User().changeInfoUser(id:user.id ,user: user)
        }
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        name.resignFirstResponder()
        surname.resignFirstResponder()
        mail.resignFirstResponder()
        phoneNumber.resignFirstResponder()
        descriptionTF.resignFirstResponder()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension ChangeInformationViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage, let url = info[.imageURL] as? URL {
            avatarImage = image
            avatarURL = "\(url)"
            addText()
            picker.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
extension ChangeInformationViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumber {
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            if newString.format(with: "+X (XXX) XXX-XXXX").count >= 2 {
                textField.text = newString.format(with: "+X (XXX) XXX-XXXX")
                return false
            } else {
                return false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activateTF = textField
    }

    
}
