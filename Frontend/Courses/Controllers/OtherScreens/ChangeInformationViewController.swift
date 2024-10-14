//
//  ChangeInformationViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 05.07.2024.
//

import UIKit
import Lottie
import CropViewController

class ChangeInformationViewController: UIViewController {

    @IBOutlet weak var heightScroll: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionTF: UITextView!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var surname: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var avatar: UIImageView!

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()

    private var avatarURL: URL?
    private var activateTF: UITextField?
    private var user: UserStruct = User.info

    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber.delegate = self
        descriptionTF.delegate = self
        name.delegate = self
        surname.delegate = self
        mail.delegate = self
        startPosition = errorView.center
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
            let textFieldBottom = textFieldRect.maxY + 100

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
        Task {
            name.autocapitalizationType = .words
            surname.autocapitalizationType = .words
            descriptionTF.textContainer.maximumNumberOfLines = 4
            descriptionTF.textContainer.lineBreakMode = .byTruncatingTail
            user = try await User().getMyInfo()
            if user.role == .user {
                descriptionView.isHidden = true
                heightScroll.constant = 530
            }else {
                descriptionView.isHidden = false
                heightScroll.constant = 650
            }
            addText()
        }
    }


    private func addText() {
        if let avatar = user.avatarURL {
            self.avatar.sd_setImage(with: avatar)
        }
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
        user.avatarURL = avatarURL
    }

    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = false
        loading.play()
    }

    @IBAction func save(_ sender: UIButton) {
        saveBtn.isEnabled = false
        Task{
            do {
                loadingSettings()
                changeUserInfo()
                try await User().changeInfoUser(id:user.id ,user: user)
                loading.stop()
                loading.isHidden = true
                saveBtn.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                view.addSubview(errorView)
                loading.stop()
                loading.isHidden = true
                saveBtn.isEnabled = true
            }
        }
    }

    @IBAction func addImage(_ sender: UIButton) {
        let privacy = Privacy().checkPhotoLibraryAuthorization()
        if privacy {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            present(imagePickerController, animated: true)
        }
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        name.resignFirstResponder()
        surname.resignFirstResponder()
        mail.resignFirstResponder()
        phoneNumber.resignFirstResponder()
        descriptionTF.resignFirstResponder()
    }

    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
extension ChangeInformationViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate, CropViewControllerDelegate {


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage, let url = info[.imageURL] as? URL {
            ImageResize().deleteTempImage(atURL: url)
            picker.dismiss(animated: true)
            let crop = CropImage(vc: self)
            crop.showAvatarCrop(with: image)
            crop.vcCrop.delegate = self
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        avatar.image = image
        avatarURL = ImageResize().imageToURL(image: image, fileName: "avatar")
        cropViewController.dismiss(animated: true)
    }

}
extension ChangeInformationViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumber {
            return ValidateTF().phone(textField, shouldChangeCharactersIn: range, replacementString: string)
        }else if textField == name || textField == surname {
            return ValidateTF().nameAndSurname(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        return true
    }



    func textFieldDidBeginEditing(_ textField: UITextField) {
        activateTF = textField
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        activateTF = phoneNumber
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        
        let currentText = textView.text ?? ""
        let newLength = currentText.count + text.count - range.length
        return newLength <= 150
    }

}
