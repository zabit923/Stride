//
//  CoursesFromStarsViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.07.2024.
//

import UIKit
import SDWebImage

class CoursesFromStarsViewController: UIViewController {

    @IBOutlet weak var CatalogCollectionView: UICollectionView!
    
    var catalog = [Catalog]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CatalogCollectionView.delegate = self
        CatalogCollectionView.dataSource = self
        
    }
    
}
extension CoursesFromStarsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catalog.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catalog", for: indexPath) as! CatalogCollectionViewCell
        cell.image.sd_setImage(with: URL(string: catalog[indexPath.row].image))
        cell.nameAuthor.text = catalog[indexPath.row].nameAuthor
        cell.nameCourse.text = catalog[indexPath.row].nameCourse
        cell.price.text = "\(catalog[indexPath.row].price)"
        cell.rating.text = "\(catalog[indexPath.row].rating)"
        return cell
    }
    
    
}
