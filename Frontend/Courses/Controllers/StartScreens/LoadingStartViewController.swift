//
//  LoadingStartViewController.swift
//  Courses
//
//  Created by Руслан on 30.08.2024.
//

import UIKit
import Lottie

class LoadingStartViewController: UIViewController {

    @IBOutlet weak var viewFon: UIView!
    @IBOutlet weak var imFon: UIImageView!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var titleLbl: UILabel!

    private var titles = [String]()
    private var images = [String]()
    
    var delegate: LoadingData!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        checkError()
        allTitle()
        allImages()
        randomImageAndTitle()
        loadingSettings()
    }
    
    private func checkError() {
        Task {
            getData()
        }
    }
    
    private func getData() {
        Task{
            let user = try await User().getMyInfo()
            let celebrities = try await User().getCelebreties()
            let recomendCourses = try await Course().getRecomendedCourses()
            delegate.getData(user: user, celebrity: celebrities, recomended: recomendCourses)
            navigationController?.popViewController(animated: false)
        }
    }
    
    

    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleAspectFill
        loading.play()
    }
    
    private func updateApp() async throws -> Bool {
        let isLastVersion = try await AppStoreVersion().checkVersionApp()
        if isLastVersion == false {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let updateViewController = storyboard.instantiateViewController(identifier: "UpdateViewController")
            navigationController!.pushViewController(updateViewController, animated: false)
        }
        return isLastVersion
    }

    private func allTitle() {
        titles.append("Превзойди себя, не сдавайся!")
        titles.append("Почувствуй себя лучше, чем когда-либо!")
        titles.append("Стань сильнее, двигайся к успеху!")
        titles.append("Подними планку, достигни максимума!")
        titles.append("Поставь новые рекорды, ощути силу!")
        titles.append("Построй тело своей мечты, ты можешь все!")
    }

    private func allImages() {
        images.append("startFon")
        images.append("startFon2")
        images.append("startFon3")
        images.append("startFon4")
        images.append("startFon5")
        images.append("startFon6")
    }

    private func randomImageAndTitle() {
        let randomTitle = Int.random(in: 0...5)
        let randomImage = Int.random(in: 0...5)
        design(image: UIImage(named: images[randomImage])!, title: titles[randomTitle])
    }

    private func design(image: UIImage, title: String) {
        titleLbl.text = title
        imFon.image = image
        if image != UIImage.startFon {
            viewFon.backgroundColor = .clear
        }
    }

}
