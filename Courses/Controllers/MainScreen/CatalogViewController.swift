//
//  ViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.07.2024.
//

import UIKit
import SDWebImage

class CatalogViewController: UIViewController {

    @IBOutlet weak var CatalogCollectionView: UICollectionView!
    @IBOutlet weak var CategoryCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CategoryCollectionView.dataSource = self
        CategoryCollectionView.delegate = self
        CatalogCollectionView.dataSource = self
        CatalogCollectionView.delegate = self
    }
    
    var categories = [Category]()
    var catalog = [Catalog]()
}

extension CatalogViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == CategoryCollectionView {
            return categories.count
        }else {
            return catalog.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == CategoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoriesCollectionViewCell
            cell.image.sd_setImage(with: URL(string: categories[indexPath.row].image))
            cell.nameCategory.text = categories[indexPath.row].nameCategory
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catalog", for: indexPath) as! CatalogCollectionViewCell
            cell.image.sd_setImage(with: URL(string: catalog[indexPath.row].image))
            cell.nameAuthor.text = catalog[indexPath.row].nameAuthor
            cell.nameCourse.text = catalog[indexPath.row].nameCourse
            cell.price.text = "\(catalog[indexPath.row].price)"
            cell.rating.text = "\(catalog[indexPath.row].rating)"
            return cell
        }
        
    }
    
    
}
