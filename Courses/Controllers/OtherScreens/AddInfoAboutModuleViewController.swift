//
//  AddInfoAboutModuleViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.08.2024.
//

import UIKit

class AddInfoAboutModuleViewController: UIViewController {

    
    
    @IBOutlet weak var closeName: UIButton!
    @IBOutlet weak var closeDuration: UIButton!
    @IBOutlet weak var closeDescription: UIButton!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        startPosition = mainView.center
        textFieldsDesign()
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
    
    private var startPosition = CGPoint()
    
    
    @objc func keyboardWillAppear(notification: Notification) {
        bottomConstraint.constant = 80
    }

    @objc func keyboardWillDisappear() {
        bottomConstraint.constant = 0
    }
    
    func design() {
        if nameTextField.text == "" {
            closeName.isHidden = true
        }else {
            closeName.isHidden = false
        }
        if descriptionTextField.text == "" {
            closeDescription.isHidden = true
        }else {
            closeDescription.isHidden = false
        }
        if durationTextField.text == "" {
            closeDuration.isHidden = true
        }else {
            closeDuration.isHidden = false
        }
    }
    
    func textFieldsDesign() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Название", attributes: [NSAttributedString.Key.foregroundColor: UIColor.forTextFields, NSAttributedString.Key.font: font!])
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Описание", attributes: [NSAttributedString.Key.foregroundColor: UIColor.forTextFields, NSAttributedString.Key.font: font!])
        durationTextField.attributedPlaceholder = NSAttributedString(string: "Длительность", attributes: [NSAttributedString.Key.foregroundColor: UIColor.forTextFields, NSAttributedString.Key.font: font!])
    }

    @IBAction func addImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
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
    
    @IBAction func save(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func clearText(currentTextField: UITextField) {
        switch currentTextField {
        case nameTextField:
            nameTextField.text = ""
        case descriptionTextField:
            descriptionTextField.text = ""
        case durationTextField:
            durationTextField.text = ""
        default:
            break
        }
    }
    
    @IBAction func clearInfo(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            clearText(currentTextField: nameTextField)
        case 1:
            clearText(currentTextField: descriptionTextField)
        case 2:
            clearText(currentTextField: durationTextField)
        default:
            break
        }
    }
    
    
    
}

extension AddInfoAboutModuleViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageBtn.setImage(image, for: .normal)
            dismiss(animated: true)
        }
    }
}
