//
//  ViewController.swift
//  memeApp
//
//  Created by Colin Walsh on 1/8/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

struct Meme {
    let top: String!
    let bottom: String!
    let image: UIImage!
    let completedImage: UIImage!
    
    init(top: String, bottom: String, image: UIImage, completedImage: UIImage) {
        self.top = top
        self.bottom = bottom
        self.image = image
        self.completedImage = completedImage
    }
}

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topLabel: UITextField!
    @IBOutlet weak var bottomLabel: UITextField!
    @IBOutlet weak var topBar: UIToolbar!
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setTextField(top: "top", bottom: "bottom")
        
        topLabel.delegate = self
        bottomLabel.delegate = self
        
        topLabel.clearsOnBeginEditing = true
        bottomLabel.clearsOnBeginEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemeViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    //From: https://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func setTextField(top: String, bottom: String) {
        //From this post
        //https://www.reddit.com/r/swift/comments/2vmtfs/text_border_color_of_label/
        topLabel.attributedText = NSAttributedString(string: top.uppercased(), attributes: textAttr())
        bottomLabel.attributedText = NSAttributedString(string: bottom.uppercased(), attributes: textAttr())
    }
   
    func textAttr() -> [NSAttributedStringKey: Any] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.strokeWidth : -3,
            NSAttributedStringKey.font : UIFont(name: "Helvetica", size: 40)!,
            NSAttributedStringKey.paragraphStyle : paragraphStyle
        ]
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let pickedImageFrame = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let finalImage = pickedImageFrame
        let activityViewController = UIActivityViewController.init(activityItems: [finalImage!], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler =
            {(activity, success, items, error) in
                if success {
                    activityViewController.dismiss(animated: true, completion: nil)
                } else if (error != nil) {
                    print(error)
                }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        setTextField(top: "top", bottom: "bottom")
        pickedImage.image = nil
        shareButton.isEnabled = false
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        //From: https://turbofuture.com/cell-phones/Access-Photo-Camera-and-Library-in-Swift
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case PHAuthorizationStatus.authorized:
                OperationQueue.main.addOperation {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            case PHAuthorizationStatus.notDetermined:
                print("Not determined")
            case PHAuthorizationStatus.restricted:
                print("Restricted")
            default:
                print("Denied")
            }
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage.contentMode = .scaleAspectFit
            pickedImage.image = image
        }
        picker.dismiss(animated: true, completion: nil)
        
        topLabel.isEnabled = true
        bottomLabel.isEnabled = true
        shareButton.isEnabled = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTextField(top: topLabel.text!, bottom: bottomLabel.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


