//
//  MemeDetailViewController.swift
//  memeApp
//
//  Created by Colin Walsh on 1/12/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    @IBOutlet weak var detailMemeImageView: UIImageView!
    
    var memeImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailMemeImageView.image = memeImage
        detailMemeImageView.contentMode = .scaleAspectFit
        detailMemeImageView.backgroundColor = .black
    }

    
    

}
