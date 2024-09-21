//
//  AddInfoAboutModuleViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.08.2024.
//

import UIKit
import SDWebImage
import Lottie
import CropViewController

class AddInfoAboutModuleViewController: UIViewController {


    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var closeName: UIButton!
    @IBOutlet weak var closeDescription: UIButton!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var descriptionTextField: UITextField!
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))

    weak var delegate: ChangeInfoModule?
    private var startPosition = CGPoint()
    var module = Modules(name: "", minutes: 0, id: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        textFieldsDesign()
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

    func design() {
        nameTextField.text = module.name
        descriptionTextField.text = module.description
        durationTextField.text = "\(module.minutes)"
        if let imageURL = module.imageURL {
            imageBtn.sd_setImage(with: imageURL, for: .normal)
        }
        checkTFByCloseBtn()
    }


    func checkTFByCloseBtn() {
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
    }

    func textFieldsDesign() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Название", attributes: [NSAttributedString.Key.foregroundColor: UIColor.forTextFields, NSAttributedString.Key.font: font!])
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Описание", attributes: [NSAttributedString.Key.foregroundColor: UIColor.forTextFields, NSAttributedString.Key.font: font!])
        durationTextField.attributedPlaceholder = NSAttributedString(string: "Длительность", attributes: [NSAttributedString.Key.foregroundColor: UIColor.forTextFields, NSAttributedString.Key.font: font!])
    }

    func changeModule() {
        if let minutes = Int(durationTextField.text!) {
            module.minutes = minutes
        }
        module.name = nameTextField.text!
        module.description = descriptionTextField.text!
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
                    self.mainView.frame.origin = self.startPosition
                }
            }
        default:
            break
        }
    }

    @IBAction func save(_ sender: UIButton) {
        saveBtn.isEnabled = false
        errorView.isHidden = true
        Task {
            do {
                changeModule()
                try await Courses().changeModuleInfo(info: module)
                delegate?.changeInfoModuleDismiss(module: module, moduleID: module.id)
                saveBtn.isEnabled = true
                dismiss(animated: true)
            } catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                view.addSubview(errorView)
                saveBtn.isEnabled = true
            }
        }
    }

    @IBAction func deleteModule(_ sender: UIButton) {
        Task {
            do {
                try await Courses().deleteModule(moduleID: module.id)
                delegate?.deleteModuleDismiss(moduleID: module.id)
                dismiss(animated: true)
            } catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                view.addSubview(errorView)
            }
        }
    }

    @IBAction func clearInfo(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            nameTextField.text = ""
        case 1:
            descriptionTextField.text = ""
        default:
            break
        }
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        durationTextField.resignFirstResponder()
    }


}

extension AddInfoAboutModuleViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate, CropViewControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage, let url = info[.imageURL] as? URL {
            ImageResize().deleteTempImage(atURL: url)
            picker.dismiss(animated: true)
            let crop = CropImage(vc: self)
            crop.showModuleImageCourse(with: image)
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
        imageBtn.setImage(image, for: .normal)
        module.imageURL = ImageResize().imageToURL(image: image, fileName: "\(UUID().uuidString)")
        cropViewController.dismiss(animated: true)
    }
    
}
