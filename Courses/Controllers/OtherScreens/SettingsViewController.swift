//
//  SettingsViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 02.07.2024.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var settingsTableView2: UITableView!
    
    var arrayObjects = [Objects]()
    var arrayObjects2 = [Objects]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView2.dataSource = self
        settingsTableView2.delegate = self
        addObjects()
    }
    
    
    func addObjects() {
        arrayObjects = [Objects(name: "Информация о себе", image: "next"), Objects(name: "История курсов", image: "next"), Objects(name: "Конфиденциальность", image: "next"), Objects(name: "Добавить курс", image: "next")]
        arrayObjects2 = [Objects(name: "Нужна помощь? Напиши нам", image: "next"), Objects(name: "Политика конфиденциальности", image: "next")]
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
            return cell
        }else{
            let cell = settingsTableView2.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! SettingsTableViewCell
            cell.im.image = UIImage(named: "\(arrayObjects2[indexPath.row].image)")
            cell.lbl.text = arrayObjects2[indexPath.row].name
            return cell
        }
    }
    
   
    
    
}
