//
//  CourseTextViewController.swift
//  Courses
//
//  Created by Руслан on 14.07.2024.
//

import UIKit
import Lottie

class CourseTextViewController: UIViewController {

    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameCourse: UILabel!

    var module = Modules(name: "", minutes: 0, id: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        design()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FilePath().deleteAlamofireFiles()
    }

    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = false
    }

    private func design() {
        self.overrideUserInterfaceStyle = .dark
        textView.textColor = .white
        loadingSettings()
        nameCourse.text = module.name
    }

    func getData() {
        Task {
            loading.play()
            if let moduleText = module.text {
                let attributedString = try await FilePath().downloadFileWithURL(url: moduleText)
                textView.attributedText = attributedString
            }
            loading.stop()
            loading.isHidden = true
        }
    }
    

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
