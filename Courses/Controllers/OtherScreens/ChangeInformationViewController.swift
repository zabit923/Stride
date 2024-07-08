//
//  ChangeInformationViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 05.07.2024.
//

import UIKit

class ChangeInformationViewController: UIViewController {
    
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var surname: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var avatar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addText()
    }
    
    private func addText() {
        avatar.image = UIImage.defaultLogo
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
