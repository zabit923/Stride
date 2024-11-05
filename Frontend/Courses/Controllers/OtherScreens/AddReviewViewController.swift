//
//  AddReviewViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 29.08.2024.
//

import UIKit

class AddReviewViewController: UIViewController {


    @IBOutlet weak var sendReviewBtn: UIButton!
    @IBOutlet weak var firstStar: UIButton!
    @IBOutlet weak var secondStar: UIButton!
    @IBOutlet weak var thirdStar: UIButton!
    @IBOutlet weak var fourthStar: UIButton!
    @IBOutlet weak var fifthStar: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var errorStartPosition = CGPoint()
    private var startPosition = CGPoint()
    var idCourse = 0
    var rating = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        design()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startPosition = viewMain.frame.origin
        errorStartPosition = errorView.center
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

    func check() -> Bool{
        var result = true
        if textView.text == ""{
            result = false
            errorView.configure(title: "Ошибка", description: "Впишите комментарий")
        }
        if textView.textColor == .gray {
            result = false
            errorView.configure(title: "Ошибка", description: "Впишите комментарий")
        }
        if rating == 0 {
            result = false
            errorView.configure(title: "Ошибка", description: "Добавьте рейтинг")
        }
        if result == false {
            errorView.isHidden = false
        }else {
            errorView.isHidden = true
        }
        return result
    }

    func design() {
        textView.delegate = self
        textView.text = "Ваш комментарий"
        textView.textColor = UIColor.gray
        view.addSubview(errorView)
        errorView.isHidden = true
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
    
    @IBAction func finish(_ sender: UIButton)  {
        sendReviewBtn.isEnabled = false
        if check() == true {
            Task {
                do {
                    try await Comments().addComment(idCourse: idCourse, rating: rating, text: textView.text)
                    sendReviewBtn.isEnabled = true
                    dismiss(animated: true)
                }catch ErrorNetwork.runtimeError(let error) {
                    errorView.isHidden = false
                    errorView.configure(title: "Ошибка", description: error)
                    sendReviewBtn.isEnabled = true
                }
            }
        }
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }

    @IBAction func rating(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            Stars().starsCount(firstButton: firstStar, secondButton: secondStar, thirdButton: thirdStar, fourthButton: fourthStar, fifthButton: fifthStar, selectButton: .firstButton)
            rating = 1
        case 1:
            Stars().starsCount(firstButton: firstStar, secondButton: secondStar, thirdButton: thirdStar, fourthButton: fourthStar, fifthButton: fifthStar, selectButton: .secondButton)
            rating = 2
        case 2:
            Stars().starsCount(firstButton: firstStar, secondButton: secondStar, thirdButton: thirdStar, fourthButton: fourthStar, fifthButton: fifthStar, selectButton: .thirdButton)
            rating = 3
        case 3:
            Stars().starsCount(firstButton: firstStar, secondButton: secondStar, thirdButton: thirdStar, fourthButton: fourthStar, fifthButton: fifthStar, selectButton: .fourtFutton)
            rating = 4
        case 4:
            Stars().starsCount(firstButton: firstStar, secondButton: secondStar, thirdButton: thirdStar, fourthButton: fourthStar, fifthButton: fifthStar, selectButton: .fifthButton)
            rating = 5
        default:
            break
        }

    }

}



extension AddReviewViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty == true {
            textView.text = "Ваш комментарий"
            textView.textColor = UIColor.gray
        }
    }
}
