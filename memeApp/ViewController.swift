//
//  ViewController.swift
//  memeApp
//
//  Created by Colin Walsh on 1/8/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate {

    @IBOutlet weak var pickedImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func pickAnImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        
        pickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage.contentMode = .scaleAspectFit
            pickedImage.image = image
        }
    }
}

