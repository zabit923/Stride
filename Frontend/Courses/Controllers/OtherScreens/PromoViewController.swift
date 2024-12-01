//
//  PromoViewController.swift
//  Courses
//
//  Created by Руслан on 25.11.2024.
//

import UIKit

class PromoViewController: UIViewController {
    
    @IBOutlet weak var promoCollectionView: UICollectionView!
    
    private var promocodes = [Promocodes]()
    private var selectPromoCode: Promocodes? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promoCollectionView.dataSource = self
        promoCollectionView.delegate = self
        getMyPromo()
    }
    
    private func getMyPromo() {
        Task {
            promocodes = try await Promocodes().getMyPromocodes()
            promoCollectionView.reloadData()
        }
    }
    

    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
extension PromoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return promocodes.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "promo", for: indexPath) as! PromoCollectionViewCell
            cell.promoName.text = promocodes[indexPath.row - 1].name
            cell.buyers.text = "Платежей (\(promocodes[indexPath.row - 1].buyers))"
            cell.courses.text = "Курсов (\(promocodes[indexPath.row - 1].countCourses))"
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "create", for: indexPath) as! PromoCollectionViewCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectPromoCode = nil
        }else {
            selectPromoCode = promocodes[indexPath.row - 1]
        }
        performSegue(withIdentifier: "createPromo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createPromo" {
            let vc = segue.destination as! CreatePromoViewController
            vc.delegate = self
            vc.promoCode = selectPromoCode
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 - 5
        return CGSize(width: width, height: 85)
    }
    
    
    
}
extension PromoViewController: PromoCodeDelegate {
    
    func delete(promoCode: Promocodes) {
        for x in 0...promocodes.count - 1 {
            if promoCode.id == promocodes[x].id {
                promocodes.remove(at: x)
                promoCollectionView.reloadData()
                return
            }
        }
    }
    
    func create(promoCode: Promocodes) {
        promocodes.append(promoCode)
        promoCollectionView.reloadData()
    }
    
    func change(promoCode: Promocodes) {
        for x in 0...promocodes.count - 1 {
            if promoCode.id == promocodes[x].id {
                promocodes[x] = promoCode
            }
        }
        promoCollectionView.reloadData()
    }
    
    
}
