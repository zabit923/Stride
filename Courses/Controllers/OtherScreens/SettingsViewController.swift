//
//  SettingsViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 02.07.2024.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var tbvConstant: NSLayoutConstraint!
    @IBOutlet weak var mail: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var settingsTableView2: UITableView!
    
    var arrayObjects = [Objects]()
    var arrayObjects2 = [Objects]()
    var user = User(role: .coach)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView2.dataSource = self
        settingsTableView2.delegate = self
        addObjects()
        design()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeHeightTable()
    }
    
    private func design() {
        addProfile()
        if user.role == .user {
            backBtn.isHidden = true
        }else {
            backBtn.isHidden = false
        }
        self.view.layoutSubviews()
    }
    
    private func changeHeightTable() {
        tbvConstant.constant = settingsTableView.contentSize.height
    }
    
    private func addProfile() {
        name.text = "Эльдар Ибрагимов"
        mail.text = "ruha20444@mail.ru"
        avatar.image = UIImage.defaultLogo
    }
    
    private func addObjects() {
        if user.role == .coach {
            arrayObjects = [Objects(name: "Информация о себе", image: "information"), Objects(name: "История курсов", image: "coursesHistory"), Objects(name: "Конфиденциальность", image: "confidentiality"), Objects(name: "Добавить курс", image: "confirmAccount")]
            arrayObjects2 = [Objects(name: "Нужна помощь? Напиши нам", image: "helper"), Objects(name: "Политика конфиденциальности", image: "political")]
        }else if user.role == .user {
            arrayObjects = [Objects(name: "Информация о себе", image: "information"), Objects(name: "История курсов", image: "coursesHistory"), Objects(name: "Конфиденциальность", image: "confidentiality"), Objects(name: "Подтвердить аккаунт", image: "confirmAccount"), Objects(name: "Стать тренером", image: "becomeCoach")]
            arrayObjects2 = [Objects(name: "Нужна помощь? Напиши нам", image: "helper"), Objects(name: "Политика конфиденциальности", image: "political")]
        }
    }

}
 
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == settingsTableView {
            return arrayObjects.count
        }else{
            return arrayObjects2.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == settingsTableView {
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingsTableViewCell
            cell.im.image = UIImage(named: "\(arrayObjects[indexPath.row].image)")
            cell.lbl.text = arrayObjects[indexPath.row].name
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = settingsTableView2.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! SettingsTableViewCell
            cell.im.image = UIImage(named: "\(arrayObjects2[indexPath.row].image)")
            cell.lbl.text = arrayObjects2[indexPath.row].name
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == settingsTableView {
            switch arrayObjects[indexPath.row].name {
            case "Информация о себе":
                performSegue(withIdentifier: "goToInfoAboutMe", sender: self)
            case "История курсов":
                performSegue(withIdentifier: "goToInfoAboutMe", sender: self)
            case "Конфиденциальность":
                performSegue(withIdentifier: "goToInfoAboutMe", sender: self)
            case "Добавить курс":
                performSegue(withIdentifier: "goToAddCourse", sender: self)
            case "Подтвердить аккаунт":
                performSegue(withIdentifier: "goToInfoAboutMe", sender: self)
            case "Стать тренером":
                performSegue(withIdentifier: "goToInfoAboutMe", sender: self)
            default:
                break
            }
        }
    }
   
    
    
}
