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
        
        //        Auth.auth().signInAnonymously { results, error in
        //            if let error = error{
        //                print(error.localizedDescription)
        //            }else{
        //                print(results?.user.uid)
        //            }
        //        }
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
                    item.downloadURL { url, error in
                        let imageView = UIImageView()
                        imageView.sd_setImage(with: url) { _, _, _, _ in
                            <#code#>
                        }
                    }
                }
            }
            
//            print("Name: \(result?.items[0].name)")
//            if let ref = result?.items[0]{
//                ref.downloadURL { url, error in
//                    self.theImageView.sd_setImage(with: url)
//                }
//            }
            
        }
    }
    
    @IBAction func nextPic(_ sender: Any) {
        
    }
    

    @IBAction func signInOut(_ sender: Any) {
        if auth.currentUser == nil{
            auth.signInAnonymously()
        }else{
            auth.currentUser?.delete(completion: { error in
                print(error?.localizedDescription)
            })
            //            do{
            //                try auth.signOut()
            //            }catch{
            //                print(error.localizedDescription)
            //            }
            //            signInButton.setTitle("Sign Out", for: .normal)
            //            print("Signed In:\(auth.currentUser?.uid)")
        }
    }
    
}

