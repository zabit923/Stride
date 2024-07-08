//
//  InfoAboutMeViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 06.07.2024.
//

import UIKit

class InfoAboutMeViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    
    private var startPosition = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startPosition = mainView.center
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
    
    @IBAction func dissmis(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
}
