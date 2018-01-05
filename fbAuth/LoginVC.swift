//
//  LoginVC.swift
//  fbAuth
//
//  Created by Rabeeh KP on 26/12/17.
//  Copyright © 2017 Rabeeh KP. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase


class LoginVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource{
    
    // MARK: -Variables
    var cellFunction = CellFunction()
    var userPhoto:NSArray?
    var clicked : Bool = true
    var fid :String!
    var arrayImages : [UIImage] = []
    
    // MARK: -Outlets
    @IBOutlet weak var fbLogin: UIButton!
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    // MARK: -View Methords
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

   
    // MARK: - Login Action
    @IBAction func fbLoginButton(_ sender: UIButton) {
        if clicked == true{
            
            FBSDKLoginManager().logIn(withReadPermissions: ["public_profile","email","user_photos"], from: self) { (result, err) in
                if err != nil{
                    print("Custom fb login failed" , err ?? "")
                    return
                }
                self.cellFunction.showEmailAddress()
                print(result?.token.tokenString)
                self.fbLogin.setTitle( "    Logout facebook", for: .normal)
                self.clicked = false
                if let _ = FBSDKAccessToken.current()
                {
                    
                    self.fetchListOfUserPhotos()
                }
                
            }
        }
        if clicked == false {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            fbLogin.setTitle("    Continue with facebook", for: .normal)
            clicked = true
        }
        dismiss(animated: false, completion: nil)
        
    }
    
    

    //MARK: -CollectionView Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var returnValue = 0
        
        if let userPhotosObject = self.userPhoto
        {
            returnValue = userPhotosObject.count
        }
        return returnValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! imgShowingCell
        if clicked == true{
            myCell.imageView.image = nil
        }
        else{
            let userPhotoObject = self.userPhoto![indexPath.row] as! NSDictionary
            let userPhotoUrlString = userPhotoObject.value(forKey: "picture") as! String
            let imageUrl:URL = URL(string: userPhotoUrlString)!
            DispatchQueue.global(qos: .userInitiated).async  {
                
                let imageData:Data = try! Data(contentsOf: imageUrl)
                // Add photo to a cell as a subview
                DispatchQueue.main.async {
                    if let image = UIImage(data: imageData){
                        
                        myCell.imageView.image = image
                        myCell.addSubview(myCell.imageView)
                    }
                }
            }
        }
        return myCell
    }
    
    //MARK: -Fetching function
    func fetchListOfUserPhotos()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/photos", parameters: ["fields":"picture"] )
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let fbResult:[String:AnyObject] = (result as! [String : AnyObject])
                let image = fbResult["data"] as! NSArray!
                self.userPhoto = image!
                    self.myCollectionView.reloadData()
            }
        })
    }
}
