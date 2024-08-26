//
//  AddCourseViewController.swift
//  Courses
//
//  Created by Руслан on 25.06.2024.
//

import UIKit
import SwiftyJSON
import Alamofire

class AddCourseViewController: UIViewController {
    
    @IBOutlet weak var nameCourseLBL: UILabel!
    @IBOutlet weak var sizeFont: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var fontTitle: UILabel!
    @IBOutlet weak var fontView: UIView!
    @IBOutlet weak var bottomConsoleView: NSLayoutConstraint!
    @IBOutlet weak var defaultAligment: UIButton!
    @IBOutlet weak var rightAligment: UIButton!
    @IBOutlet weak var centerAlingment: UIButton!
    @IBOutlet weak var leftAlingment: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    
    var module = Modules(name: "", minutes: 0, id: 0)
    var nameCourse = ""
    
    private var colorSelect = UIColor.white {
        didSet {
            colorView.backgroundColor = colorSelect
            textView.typingAttributes[.foregroundColor] = colorSelect
        }
    }
    private var fontSelect = UIFont.systemFont(ofSize: 16) {
        didSet {
            fontTitle.text = fontSelect.fontName
            textView.typingAttributes[.font] = fontSelect
        }
    }
    private var alignment = NSMutableParagraphStyle().alignment {
        didSet {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = alignment
            textView.typingAttributes[.paragraphStyle] = paragraph
            clearTextAlingment()
            changedAlignment(alignment)
        }
    }
    private var sizeFontSelect = 16.0 {
        didSet {
            fontSelect = UIFont(descriptor: fontSelect.fontDescriptor, size: sizeFontSelect)
            sizeFont.text = "\(sizeFontSelect) пт"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textColor = .white
        textView.delegate = self
        view.overrideUserInterfaceStyle = .dark
        getData()
        design()
        startPosition = errorView.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillAppear(notification:Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomConsoleView.constant = keyboardHeight - 30
        }
    }

    @objc func keyboardWillDisappear() {
        bottomConsoleView.constant = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        FilePath().deleteAlamofireFiles()
    }
    
    

    func getData() {
        Task {
            let attributedString = try await FilePath().downloadFileWithURL(url: module.text!)
            textView.attributedText = attributedString
        }
    }
    
    private func design() {
        nameCourseLBL.text = nameCourse
    }
    
    
    private func changedAlignment(_ alignment: NSTextAlignment) {
        switch alignment {
        case .left:
            leftAlingment.setImage(UIImage.leftTextFull, for: .normal)
        case .center:
            centerAlingment.setImage(UIImage.centerTextFull, for: .normal)
        case .right:
            rightAligment.setImage(UIImage.rightTextFull, for: .normal)
        case .natural:
            defaultAligment.setImage(UIImage.defaulTextFull, for: .normal)
        default:
            break
        }
    }
    
    private func clearTextAlingment() {
        leftAlingment.setImage(UIImage.leftText, for: .normal)
        centerAlingment.setImage(UIImage.centerText, for: .normal)
        rightAligment.setImage(UIImage.rightText, for: .normal)
        defaultAligment.setImage(UIImage.defaultText, for: .normal)
    }
    
    private func selectText(attributes: [NSAttributedString.Key: Any]) {
        guard let selectedRange = textView.selectedTextRange else { return }
        let selectedText = textView.text(in: selectedRange)
        guard selectedText != "" else {return}
        let nsRange = textView.convertUITextRangeToNSRange(range: selectedRange)
        textView.textStorage.addAttributes(attributes, range: nsRange)
        textView.selectedTextRange = selectedRange
    }
    
    
    private func addCourse(text: NSAttributedString) async throws {
        do {
            try await Courses().addModulesData(text: text, moduleID: module.id)
        }catch ErrorNetwork.runtimeError(let error) {
            errorView.isHidden = false
            errorView.configure(title: "Ошибка", description: error)
            view.addSubview(errorView)
        }
    }
    
    // MARK: - UIButton

    @IBAction func okFont(_ sender: Any) {
        fontView.isHidden = true
        textView.isEditable = true
        textView.becomeFirstResponder()
        selectText(attributes: [.font: fontSelect, .foregroundColor: colorSelect])
    }
    
    
    
    @IBAction func save(_ sender: UIButton) {
        textView.resignFirstResponder()
        Task {
            try await addCourse(text: textView.attributedText)
        }
    }
    
    @IBAction func color(_ sender: UIButton) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = colorView.backgroundColor!
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @IBAction func changedText(_ sender: UIButton) {
        textView.resignFirstResponder()
        textView.isEditable = false
        fontView.isHidden = false
        textStyleBar()
    }
    
    @IBAction func fontBtn(_ sender: UIButton) {
        let config = UIFontPickerViewController.Configuration()
        config.includeFaces = false
        let vc = UIFontPickerViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func alignment(_ sender: UIButton) {
        clearTextAlingment()
        switch sender.tag {
        case 0:
            alignment = .left
        case 1:
            alignment = .center
        case 2:
            alignment = .right
        case 3:
            alignment = .natural
        default:
            break
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        selectText(attributes: [.paragraphStyle: paragraph])
    }

    @IBAction func stepper(_ sender: UIButton) {
        if sender.tag == 0 {
            sizeFontSelect -= 1
        }else {
            sizeFontSelect += 1
        }
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }
    
    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
// MARK: - TextView
extension AddCourseViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.typingAttributes[.font] as? UIFont != fontSelect {
            textView.typingAttributes[.font] = fontSelect
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textStyleBar()
    }
    
    private func textStyleBar() {
        if let font = textView.typingAttributes[.font] as? UIFont {
            fontSelect = font
            sizeFontSelect = font.pointSize
        }else {
            let font = fontSelect
            fontSelect = font
            let size = sizeFont
            sizeFont = size
        }
        if let color = textView.typingAttributes[.foregroundColor] as? UIColor {
            colorSelect = color
        }else {
            let color = colorSelect
            colorSelect = color
        }
        if let align = textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle {
            alignment = align.alignment
        }
    }
    
}
// MARK: - Image
extension AddCourseViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            let screenWidth = UIScreen.main.bounds.width - 30
            let maxSize = CGSize(width: screenWidth, height: 400)
            let scaledImage = image.scaleImage(toSize: maxSize)
            let roundedImage = scaledImage.withRoundedCorners(radius: 7)
            addImageInTextView(image: roundedImage)
            picker.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
    
    private func addImageInTextView(image: UIImage) {
        let attachment = NSTextAttachment()
        attachment.image = image
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        let combinedString = NSMutableAttributedString(attributedString: self.textView.attributedText)
        combinedString.insert(attributedString, at: textView.selectedRange.location)
        self.textView.attributedText = combinedString
    }

    
}
// MARK: - Font
extension AddCourseViewController: UIFontPickerViewControllerDelegate {
    
    func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        guard let descriptor = viewController.selectedFontDescriptor else {return}
        fontSelect = UIFont(descriptor: descriptor, size: sizeFontSelect)
        viewController.dismiss(animated: true)
    }
}
// MARK: - Color
extension AddCourseViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorSelect = viewController.selectedColor
    }
    
}
