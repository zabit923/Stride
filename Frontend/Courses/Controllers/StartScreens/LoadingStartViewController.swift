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

    override func viewDidLoad() {
        super.viewDidLoad()
        allTitle()
        allImages()
        randomImageAndTitle()
        loadingSettings()
    }

    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleAspectFill
        loading.play()
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
