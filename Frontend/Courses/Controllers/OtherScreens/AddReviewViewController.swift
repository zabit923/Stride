//
//  AddReviewViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 29.08.2024.
//

import UIKit

class AddReviewViewController: UIViewController {


    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var startPosition = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startPosition = viewMain.frame.origin
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
        bottomConstraint.constant = 250
    }

    @objc func keyboardWillDisappear() {
        bottomConstraint.constant = 0
    }
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: viewMain)
        switch sender.state {
        case .changed:
            guard translation.y > 0 else { return }
            viewMain.center = CGPoint(x: viewMain.center.x, y: viewMain.center.y +  translation.y)
            sender.setTranslation(CGPoint.zero, in: viewMain)
        case .ended:
            if sender.velocity(in: viewMain).y > 500 {
                dismiss(animated: false)
            }else {
                UIView.animate(withDuration: 0.5) {
                    self.viewMain.frame.origin = self.startPosition
                }
            }
        default:
            break
        }
    }
    @IBAction func finish(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }
}
