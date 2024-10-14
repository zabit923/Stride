//
//  AddCourseViewController.swift
//  Courses
//
//  Created by Руслан on 25.06.2024.
//

import UIKit
import SwiftyJSON
import Alamofire
import Lottie

class AddCourseViewController: UIViewController {

    @IBOutlet weak var redo: UIButton!
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var nameCourseLBL: UILabel!
    @IBOutlet weak var sizeFont: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var fontTitle: UILabel!
    @IBOutlet weak var fontView: UIView!
    @IBOutlet weak var bottomConsoleView: NSLayoutConstraint!
    @IBOutlet weak var alingment: UIButton!
    @IBOutlet weak var textView: UITextView!

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    private var isChangedText = false
    private var isSave = true

    var module = Modules(name: "", minutes: 0, id: 0)
    var nameCourse = ""
    

    private var colorSelect = UIColor.white {
        didSet {
            colorView.backgroundColor = colorSelect
//            textView.typingAttributes[.foregroundColor] = colorSelect
            selectText(attributes: [.font: fontSelect, .foregroundColor: colorSelect])
        }
    }
    private var fontSelect = UIFont.systemFont(ofSize: 16) {
        didSet {
            fontTitle.text = fontSelect.fontName
//            textView.typingAttributes[.font] = fontSelect
            selectText(attributes: [.font: fontSelect, .foregroundColor: colorSelect])
        }
    }
    private var alignment = NSMutableParagraphStyle().alignment {
        didSet {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = alignment
//            textView.typingAttributes[.paragraphStyle] = paragraph
            changedAlignment(alignment)
            selectText(attributes: [.paragraphStyle: paragraph])
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
        textView.allowsEditingTextAttributes = true
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
    
    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.play()
        loading.isHidden = false
    }

    private func loadingStop() {
        loading.stop()
        loading.isHidden = true
    }


    func getData() {
        Task {
            loadingSettings()
            guard let module = module.text else {
                loadingStop()
                return
            }
            let attributedString = try await FilePath().downloadFileWithURL(url: module)
            textView.attributedText = attributedString
            loadingStop()
        }
    }

    private func design() {
        nameCourseLBL.text = module.name
    }


    private func changedAlignment(_ alignment: NSTextAlignment) {
        switch alignment {
        case .left:
            alingment.setImage(UIImage.leftTextFull, for: .normal)
            alingment.tag = 1
        case .center:
            alingment.setImage(UIImage.centerTextFull, for: .normal)
            alingment.tag = 2
        case .right:
            alingment.setImage(UIImage.rightTextFull, for: .normal)
            alingment.tag = 3
        case .justified:
            alingment.setImage(UIImage.defaulTextFull, for: .normal)
            alingment.tag = 0
        default:
            break
        }
    }

    private func checkUndoRedo() {
        if textView.undoManager?.canUndo == true {
            undo.setImage(UIImage.undoFill, for: .normal)
        }else {
            undo.setImage(UIImage.undo, for: .normal)
        }
        
        if textView.undoManager?.canRedo == true {
            redo.setImage(UIImage.rendoFill, for: .normal)
        }else {
            redo.setImage(UIImage.rendo, for: .normal)
        }
    }
    

    private func selectText(attributes: [NSAttributedString.Key: Any]) {
        guard let selectedRange = textView.selectedTextRange else { return }
        let selectedText = textView.text(in: selectedRange)
        guard selectedText != "" else {return}
        let nsRange = textView.convertUITextRangeToNSRange(range: selectedRange)
        let previousAttributes = textView.attributedText.attributedSubstring(from: nsRange)
        textView.replaceRange(nsRange, withAttributedText: previousAttributes)
        textView.textStorage.addAttributes(attributes, range: nsRange)
        textView.selectedTextRange = selectedRange
        checkUndoRedo()
    }


    private func addCourse(text: NSAttributedString) async throws {
        do {
            loadingSettings()
            try await Course().addModulesData(text: text, moduleID: module.id)
            loadingStop()
            isSave = true
        }catch ErrorNetwork.runtimeError(let error) {
            errorView.isHidden = false
            errorView.configure(title: "Ошибка", description: error)
            view.addSubview(errorView)
            loadingStop()
        }
    }
    
    private func warningSave() {
        let alert = UIAlertController(title: "Вы не сохранили изменения", message: "Вы точно хотите выйти?", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            self.dismiss(animated: true)
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    // MARK: - UIButton

    @IBAction func okFont(_ sender: Any) {
        fontView.isHidden = true
        textView.isEditable = true
        textView.becomeFirstResponder()
        isChangedText = false
        checkUndoRedo()
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
        let privacy = Privacy().checkPhotoLibraryAuthorization()
        if privacy {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            present(imagePickerController, animated: true)
        }
    }

    @IBAction func changedText(_ sender: UIButton) {
        textView.isSelectable = true
        textView.isEditable = false
        textView.becomeFirstResponder()
        fontView.isHidden = false
        isChangedText = true
        textStyleBar()
    }

    @IBAction func fontBtn(_ sender: UIButton) {
        let config = UIFontPickerViewController.Configuration()
        config.includeFaces = false
        let vc = UIFontPickerViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if sender.tag == 0 {
            textView.undoManager?.undo()
        }else {
            textView.undoManager?.redo()
        }
        checkUndoRedo()
    }
    
    @IBAction func alignment(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            alignment = .left
            sender.tag = 1
        case 1:
            alignment = .center
            sender.tag = 2
        case 2:
            alignment = .right
            sender.tag = 3
        case 3:
            alignment = .justified
            sender.tag = 0
        default:
            break
        }
    }

    @IBAction func stepper(_ sender: UIButton) {
        if sender.tag == 0 {
            sizeFontSelect -= 1
        }else {
            sizeFontSelect += 1
        }
    }


    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }

    @IBAction func back(_ sender: UIButton) {
        if isSave == false {
            warningSave()
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

// MARK: - TextView
extension AddCourseViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let selectedRange = textView.selectedRange

        if selectedRange.length > 0 && isChangedText {
            let attributedText = textView.attributedText!
            
            let font = attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont ?? textView.font
            let color = attributedText.attribute(.foregroundColor, at: selectedRange.location, effectiveRange: nil) as? UIColor ?? textView.textColor
            
            let size = font!.pointSize
            
            fontSelect = font!
            colorSelect = color!
            sizeFontSelect = size
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.typingAttributes[.font] as? UIFont != fontSelect {
            textView.typingAttributes[.font] = fontSelect
        }
        
    }

    func textViewDidChange(_ textView: UITextView) {
        checkUndoRedo()
        isSave = false
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
        if let image = info[.originalImage] as? UIImage, let url = info[.imageURL] as? URL {
            ImageResize().deleteTempImage(atURL: url)
            let resizeImage = ImageResize.resizeAndCompressImage(image: image, maxSizeKB: 100)
            let roundedImage = resizeImage.withRoundedCorners(radius: 7)
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
