//
//  AddCourseViewController.swift
//  Courses
//
//  Created by Руслан on 25.06.2024.
//

import UIKit

class AddCourseViewController: UIViewController {
    
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
    
    private let stringTextViewArray = NSMutableAttributedString()
    private let imagePickerController = UIImagePickerController()
    private var colorSelect = UIColor.white
    private var fontSelect = UIFont.systemFont(ofSize: 16)
    private var alignment = NSMutableParagraphStyle().alignment
    private var sizeFontSelect = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        imagePickerController.delegate = self
        getData()
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
    
    private func getData() {
        DispatchQueue.global(qos: .userInteractive).async {
            if let text = UserDefaults.standard.string(forKey: "text") {
                if let dataText = Data(base64Encoded: text) {
                    let result = dataText.retrieveDataToString()
                    DispatchQueue.main.async {
                        self.textView.attributedText = result
                    }
                }
            }
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
        let font = textView.textStorage.attribute(.font, at: nsRange.location, effectiveRange: nil)  as? UIFont
    }
    
    // MARK: - UIButton

    @IBAction func okFont(_ sender: Any) {
        fontView.isHidden = true
        textView.isEditable = true
        fontSelect.withSize(sizeFontSelect)
        selectText(attributes: [.font: fontSelect, .foregroundColor: colorSelect])
    }
    
    
    
    @IBAction func save(_ sender: UIButton) {
        textView.resignFirstResponder()
//        let data = textView.attributedText.attributedStringToData()
//        let base64 = data!.base64EncodedString()
//        print(base64)
//        UserDefaults.standard.set(base64, forKey: "text")
    }
    
    @IBAction func color(_ sender: UIButton) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = colorView.backgroundColor!
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        present(imagePickerController, animated: true)
    }
    
    @IBAction func changedText(_ sender: UIButton) {
        textView.resignFirstResponder()
        fontView.isHidden = false
        textView.isEditable = false
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
            sender.setImage(UIImage.leftTextFull, for: .normal)
            alignment = .left
        case 1:
            sender.setImage(UIImage.centerTextFull, for: .normal)
            alignment = .center
        case 2:
            sender.setImage(UIImage.rightTextFull, for: .normal)
            alignment = .right
        case 3:
            sender.setImage(UIImage.defaulTextFull, for: .normal)
            alignment = .natural
        default:
            break
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        selectText(attributes: [.paragraphStyle: paragraphStyle])
    }

    @IBAction func stepper(_ sender: UIButton) {
        if sender.tag == 0 {
            sizeFontSelect -= 1
        }else {
            sizeFontSelect += 1
        }
        sizeFont.text = "\(sizeFontSelect) пт"
        fontSelect = UIFont(descriptor: fontSelect.fontDescriptor, size: sizeFontSelect)
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }
    
    
}
// MARK: - TextView
extension AddCourseViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        alignmentStyle()
        textStyle()
        textChanged()
        return true
    }
    
    func textChanged() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        let attributes: [NSAttributedString.Key: Any] = [
            .font: fontSelect,
            .foregroundColor: colorSelect,
            .paragraphStyle: paragraph
        ]
        textView.typingAttributes = attributes
    }
    
    func textStyle() {
        if let color = textView.typingAttributes[.foregroundColor] as? UIColor {
            colorView.backgroundColor = color
        }
        if let font = textView.typingAttributes[.font] as? UIFont {
            fontTitle.text = font.fontName
            sizeFont.text = "\(font.pointSize) пт"
        }
    }
    
    func alignmentStyle() {
        clearTextAlingment()
        switch textView.textAlignment.rawValue {
        case 0:
            leftAlingment.setImage(UIImage.leftTextFull, for: .normal)
        case 1:
            centerAlingment.setImage(UIImage.centerTextFull, for: .normal)
        case 2:
            rightAligment.setImage(UIImage.rightTextFull, for: .normal)
        case 4:
            defaultAligment.setImage(UIImage.defaulTextFull, for: .normal)
        default:
            break
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

            addImageInTextView(image: scaledImage)
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
        let attributedString =  NSAttributedString(attachment: attachment)
        let combinedString = NSMutableAttributedString(attributedString: self.textView.attributedText)
        combinedString.append(attributedString)
        combinedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: combinedString.length))
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
        fontTitle.text = descriptor.postscriptName
        fontSelect = UIFont(descriptor: descriptor, size: sizeFontSelect)
        viewController.dismiss(animated: true)
    }
}
// MARK: - Color
extension AddCourseViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorSelect = viewController.selectedColor
        colorView.backgroundColor = colorSelect
    }
    
}
