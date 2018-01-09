//
//  ViewController.swift
//  memeApp
//
//  Created by Colin Walsh on 1/8/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import UIKit
import Photos

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
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setDefaultText()
        
        topLabel.delegate = self
        bottomLabel.delegate = self
        
        topLabel.clearsOnBeginEditing = true
        bottomLabel.clearsOnBeginEditing = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func setDefaultText() {
        //From this post
        //https://www.reddit.com/r/swift/comments/2vmtfs/text_border_color_of_label/
        topLabel.attributedText = NSAttributedString(string: "TOP", attributes: textAttr())
        bottomLabel.attributedText = NSAttributedString(string: "BOTTOM", attributes: textAttr())
       
        topLabel.isEnabled = false
        bottomLabel.isEnabled = false
    }
   
    //From: https://stackoverflow.com/questions/25693130/move-textfield-when-keyboard-appears-swift
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
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
        UIGraphicsBeginImageContext(self.pickedImage.frame.size)
        view.drawHierarchy(in: self.pickedImage.frame, afterScreenUpdates: true)
        let pickedImageFrame = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let finalImage = pickedImageFrame
        let activityViewController = UIActivityViewController.init(activityItems: [finalImage], applicationActivities: nil)
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
        setDefaultText()
        pickedImage.image = nil
        shareButton.isEnabled = false
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

