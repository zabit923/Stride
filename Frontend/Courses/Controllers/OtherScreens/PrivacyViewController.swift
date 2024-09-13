//
//  PrivacyViewController.swift
//  Courses
//
//  Created by Руслан on 30.08.2024.
//

import UIKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        settingTextView()
    }

    private func settingTextView() {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 20.0
        paragraphStyle.maximumLineHeight = 20.0
        paragraphStyle.minimumLineHeight = 20.0
        let ats = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: UIColor.white]
        textView.attributedText = NSAttributedString(string: textView.text, attributes: ats)
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
