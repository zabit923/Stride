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
    @IBOutlet weak var settingsCollectionView: UICollectionView!
    @IBOutlet weak var settingsTableView2: UITableView!

    var arrayObjects = [Objects]()
    var arrayObjects2 = [Objects]()
    var user: UserStruct = User.info {
        didSet {
            addProfile()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsCollectionView.delegate = self
        settingsCollectionView.dataSource = self
        settingsTableView2.dataSource = self
        settingsTableView2.delegate = self
        addObjects()
        hiddenBtn()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        design()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeHeightTable()
    }

    private func design() {
        Task {
            user = try await User().getMyInfo()
            self.view.layoutSubviews()
        }
    }

    private func hiddenBtn() {
        if user.role == .user || user.role == .admin  {
            backBtn.isHidden = true
        }else if user.role == .coach {
            backBtn.isHidden = false
        }
    }

    private func changeHeightTable() {
        tbvConstant.constant = settingsCollectionView.contentSize.height
    }

    private func addProfile() {
        name.text = "\(user.name) \(user.surname)"
        mail.text = user.email
        if let ava = user.avatarURL {
            avatar.sd_setImage(with: ava)
        }
    }

    private func addObjects() {
        if user.role == .coach {
            arrayObjects = [Objects(name: "Информация о себе", image: "information", imageForBtn: "next2"), Objects(name: "Мои курсы", image: "coursesHistory", imageForBtn: "next2"), Objects(name: "Конфиденциальность", image: "confidentiality", imageForBtn: "next2"), Objects(name: "Добавить курс", image: "confirmAccount", imageForBtn: "next2"), Objects(name: "Кошелёк", image: "wallet", imageForBtn: "next2"), Objects(name: "Промокоды", image: "promoSettings", imageForBtn: "next2")]
            arrayObjects2 = [Objects(name: "Нужна помощь? Напиши нам", image: "helper", imageForBtn: "next2"), Objects(name: "Политика конфиденциальности", image: "political", imageForBtn: "next2")]
        }else if user.role == .user {
            arrayObjects = [Objects(name: "Информация о себе", image: "information", imageForBtn: "next2"), Objects(name: "Мои курсы", image: "coursesHistory", imageForBtn: "next2"), Objects(name: "Конфиденциальность", image: "confidentiality", imageForBtn: "next2"), /*Objects(name: "Подтвердить аккаунт", image: "confirmAccount", imageForBtn: "next2"),*/ Objects(name: "Стать тренером", image: "becomeCoach", imageForBtn: "next2")]
            arrayObjects2 = [Objects(name: "Нужна помощь? Напиши нам", image: "helper", imageForBtn: "next2"), Objects(name: "Политика конфиденциальности", image: "political", imageForBtn: "next2")]
        }else if user.role == .admin {
            arrayObjects = [Objects(name: "Информация о себе", image: "information", imageForBtn: "next2"), Objects(name: "Мои курсы", image: "coursesHistory", imageForBtn: "next2"), Objects(name: "Конфиденциальность", image: "confidentiality", imageForBtn: "next2"), Objects(name: "Админ панель", image: "adminPanel", imageForBtn: "next2")]
            arrayObjects2 = [Objects(name: "Нужна помощь? Напиши нам", image: "helper", imageForBtn: "next2"), Objects(name: "Политика конфиденциальности", image: "political", imageForBtn: "next2")]
        }
    }


    @IBAction func logOut(_ sender: UIButton) {
        UD().clearUD()
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsMain", for: indexPath) as! SettingsCollectionViewCell
        cell.im.image = UIImage(named: arrayObjects[indexPath.row].image)
        cell.name.text = arrayObjects[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch arrayObjects[indexPath.row].name {
        case "Информация о себе":
            performSegue(withIdentifier: "goToInfoAboutMe", sender: self)
        case "Мои курсы":
            performSegue(withIdentifier: "myCourse", sender: self)
        case "Конфиденциальность":
            performSegue(withIdentifier: "conf", sender: self)
        case "Добавить курс":
            performSegue(withIdentifier: "goToAddCourse", sender: self)
//            case "Подтвердить аккаунт":
//                UIApplication.shared.open(Constants.formsURL)
        case "Стать тренером":
            UIApplication.shared.open(Constants.formsURL)
        case "Кошелёк":
            performSegue(withIdentifier: "goToWithdraw", sender: self)
        case "Админ панель":
            performSegue(withIdentifier: "admin", sender: self)
        case "Промокоды":
            performSegue(withIdentifier: "promo", sender: self)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthScreen = UIScreen.main.bounds.width - 50
        let widthCell = widthScreen / 2
        return CGSize(width: widthCell, height: 100)
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayObjects2.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView2.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! SettingsTableViewCell
        cell.im.image = UIImage(named: "\(arrayObjects2[indexPath.row].image)")
        cell.lbl.text = arrayObjects2[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch arrayObjects2[indexPath.row].name {
        case "Политика конфиденциальности":
            performSegue(withIdentifier: "privacy", sender: self)
        case "Нужна помощь? Напиши нам":
            UIApplication.shared.open(Constants.telegramURL)
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "myCourse" {
            let vc = segue.destination as! CoursesViewController
            vc.typeCourse = .myCreate
        }else if segue.identifier == "goToAddCourse" {
            let vc = segue.destination as! AddInfoAboutCourseVC
            vc.create = true
        }else if segue.identifier == "goToWithdraw" {
            let vc = segue.destination as! WithdrawViewController
            vc.money = user.coach.money
        }

    }



}
