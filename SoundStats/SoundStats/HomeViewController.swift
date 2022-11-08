//
//  HomeViewController.swift
//  SoundStats
//
//  Created by Mya Mahaley on 11/4/22.
//

import UIKit
import Placid

class HomeViewController: UIViewController {
    @IBOutlet weak var segVC: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    let mainTemplate = PlacidSDK.template(withIdentifier: "qlmhe8hvu")
    let moodTemplate = PlacidSDK.template(withIdentifier: "wf1xyvyhu")
    let topSongsTemplate = PlacidSDK.template(withIdentifier: "1jrtyolls")
    //let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
    //present(vc, animated: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTemplate!.preload()
        moodTemplate!.preload()
        topSongsTemplate!.preload()
        //loadMainImage()
        
    }
    
    func loadMainImage() {
        mainTemplate!.renderImage(completion: { [weak self] mainImage in
            self?.imageView.image = mainImage
        })
    }
    
    func loadMoodImage() {
        moodTemplate!.renderImage(completion: { [weak self] moodImage in
            self?.imageView.image = moodImage
        })
    }
    
    func loadTopSongsImage() {
        topSongsTemplate!.renderImage(completion: { [weak self] topSongsImage in
            self?.imageView.image = topSongsImage
        })
        
    }
    

    @IBAction func segChanged(_ sender: Any) {
        switch segVC.selectedSegmentIndex {
            case 0:
                loadMainImage()
            case 1:
                loadMoodImage()
            case 2:
                loadTopSongsImage()
            default:
                print("Unknown Error")
        }
    }

}
