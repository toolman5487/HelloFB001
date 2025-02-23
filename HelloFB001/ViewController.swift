//
//  ViewController.swift
//  HelloFB001
//
//  Created by Willy Hsu on 2024/12/11.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var theImageView: UIImageView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    let auth = Auth.auth()
    let ref = Storage.storage().reference()
    var imageViews:[UIImageView] = []
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reLoadPicture()
        stateChangeListener()
        
        
    }
    func stateChangeListener(){
        auth.addStateDidChangeListener { auth, user in
            if user == nil{
                self.signInButton.setTitle("Sign In", for: .normal)
            }else{
                self.signInButton.setTitle("Sign Out", for: .normal)
                print("Signed In:\(user!.uid)")
            }
        }
    }
    
    func reLoadPicture(){
        ref.child("test001").listAll { result, error in
            if let error = error {
                print("ERRORXXX \(error.localizedDescription)")
                return
            }
            
            self.imageViews.removeAll()
            
            if let items = result?.items{
                for item in items {
                    
                    item.getMetadata { metaData, error in
                        if let error = error {
                            print("ERRORXXX \(error.localizedDescription)")
                            return
                        }
                        print("AAAsize: \(metaData?.size)")
                        print("AAAmyKey: \(metaData?.customMetadata?["myKey"])")
                        
                        if metaData?.customMetadata?["myKey"] == "myFile"{
                            item.downloadURL { url, error in
                                let imageView = UIImageView()
                                imageView.sd_setImage(with: url) { _, _, _, _ in
                                    self.imageViews.append(imageView)
                                    self.nextBtn.setTitle("目前為第\(self.currentIndex + 1)張,共\(self.imageViews.count)張", for: .normal)
                                    
                                    if self.imageViews.count == 1{
                                        self.currentIndex = 0
                                        self.theImageView.image = self.imageViews[0].image
                                        self.nextBtn.isEnabled = false
                                    }else{
                                        self.nextBtn.isEnabled = true
                                    }
                                    print("Count: \(self.imageViews.count)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func selectPic(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func nextPic(_ sender: Any) {
        nextBtn.setTitle("目前為第\(currentIndex + 1)張,共\(imageViews.count)張", for: .normal)
        currentIndex += 1
        currentIndex %= imageViews.count
        theImageView.image = imageViews[currentIndex].image
        
    }
    
    
    @IBAction func signInOut(_ sender: Any) {
        if auth.currentUser == nil{
            auth.signInAnonymously()
        }else{
            auth.currentUser?.delete(completion: { error in
                print(error?.localizedDescription)
            })
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            theImageView.image = image
            let alert = UIAlertController(title: nil, message: "是否上傳照片", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
                self.theImageView.image = self.imageViews[self.currentIndex].image
            }))
            alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { action in
                if let data = image.jpegData(compressionQuality: 0.5){
                    let newRef = self.ref.child("test001").child("\(UUID()).jpg")
                    let metaData = StorageMetadata()
                    metaData.customMetadata = ["myKey":"myFile"]
                    newRef.putData(data,metadata: metaData){ _, _ in
                        self.reLoadPicture()
                        
                    }
                }
            }))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
