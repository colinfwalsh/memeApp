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

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topLabel: UITextField!
    @IBOutlet weak var bottomLabel: UITextField!
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setTextField(top: "top", bottom: "bottom")
        
        view.backgroundColor = .black
        
        topLabel.delegate = self
        bottomLabel.delegate = self
        
        topLabel.clearsOnBeginEditing = true
        bottomLabel.clearsOnBeginEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomLabel.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification) - (tabBarController?.tabBar.frame.height)!
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
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
    
    func toggleToolbars() {
        topBar.isHidden = !topBar.isHidden
        bottomBar.isHidden = !bottomBar.isHidden
        tabBarController?.tabBar.isHidden = !(tabBarController?.tabBar.isHidden)!
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        toggleToolbars()
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let finalMemeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let activityViewController = UIActivityViewController.init(activityItems: [finalMemeImage ?? UIImage()], applicationActivities: nil)
        
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        
        
        activityViewController.completionWithItemsHandler =
            {(activity, success, items, error) in
                if success {
                    OperationQueue.main.addOperation {
                        self.save(with: Meme(top: self.topLabel.text!, bottom: self.bottomLabel.text!, image: self.pickedImage.image, completedImage: finalMemeImage!))
                        activityViewController.dismiss(animated: true, completion: nil)
                    }
                } else if (error != nil) {
                    print(error!)
                }
        }
        
        toggleToolbars()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openImagePicker(_ sender: Any) {
        //From: https://turbofuture.com/cell-phones/Access-Photo-Camera-and-Library-in-Swift
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
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
    
    func save(with meme: Meme) {
        
        // Add it to the memes array in the Application Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
}

extension MemeViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTextField(top: topLabel.text!, bottom: bottomLabel.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


