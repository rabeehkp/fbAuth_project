//
//  ViewController.swift
//  fbAuth
//
//  Created by Rabeeh KP on 21/12/17.
//  Copyright © 2017 Rabeeh KP. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,CustomLayOutDelegate{
    
    //MARK: -Variables
    var arrayImages : [UIImage] = []
    var imgResult : [UIImage] = []
    var clicked : Bool = true
    var userPhotos:NSArray!
    var cellFunction = CellFunction()
    
    //MARK: -Outlets
    @IBOutlet weak var facebookLogin: UIButton!
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    //MARK: -View Metherds
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: -Button Actions
    @IBAction func facebookLogin(_ sender: UIButton) {
        if clicked == true{
            FBSDKLoginManager().logIn(withReadPermissions: ["public_profile","email","user_photos"], from: self) { (result, err) in
                if err != nil{
                    print("Custom fb login failed" , err ?? "")
                    return
                }
                self.cellFunction.showEmailAddress()
                print(result?.token.tokenString)
                self.facebookLogin.setTitle( "    Logout facebook", for: .normal)
                self.clicked = false
                if let fetching = FBSDKAccessToken.current()
                {
                    self.fetchListOfUserPhotos()
                }
            }
        }
        if clicked == false {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            facebookLogin.setTitle("    Continue with facebook", for: .normal)
            clicked = true
        }
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: -CollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var returnValue = 0
        if let userPhotosObject = self.userPhotos
        {
            returnValue = userPhotosObject.count
        }
        return returnValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageViewCell
        if clicked == true{
            myCell.imageView.image = nil
        }
        else{
//            let userPhotoObject = self.userPhotos![indexPath.row] as! NSDictionary
//            let userPhotoUrlString = userPhotoObject.value(forKey: "picture") as! String
//            let imageUrl:URL = URL(string: userPhotoUrlString)!
//
//            DispatchQueue.global(qos: .userInitiated).async  {
//
//                let imageData:Data = try! Data(contentsOf: imageUrl)
//                // Add photo to a cell as a subview
//                DispatchQueue.main.async {
//                    if let image = UIImage(data: imageData){
//                        myCell.imageView.image = image
//                        myCell.addSubview(myCell.imageView)
//                    }
//                }
            myCell.imageView.image = imgResult[indexPath.row]
            print(myCell.imageView.image)
            //(named: imgResult[indexPath.row])
            }
        
        return myCell
    }
    
    //MARK: -Custom Delegate
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return imgResult[indexPath.row].size.height
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return imgResult[indexPath.row].size.width
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
                self.userPhotos = image!
                if self.imgResult.count != self.userPhotos?.count{
                    for item in 0...(self.userPhotos!.count - 1){
                        let res = self.userPhotos![item] as! NSDictionary
                        let userPhotoString = res.value(forKey: "picture") as! String
                        let imageUrl:URL = URL(string: userPhotoString)!
                        DispatchQueue.global(qos: .userInitiated).async  {
                            let imageData:Data = try! Data(contentsOf: imageUrl)
                            // Add photo to a cell as a subview
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData){
                                    self.imgResult.append(image)
                                    print(">>>>> \(item)")
                                    print(self.imgResult)
                                }
                                else{
                                    print("error")
                                }
                                if self.imgResult.count == self.userPhotos!.count{
                                    self.callCustomLayout()
                                }
                            }
                           
                        }
                        
                    }
                }
            }
        })
    }
    
    //MARK: -Calling custom layout
    func callCustomLayout(){
        if let layOut = myCollectionView?.collectionViewLayout as? customImgLayout
        {
            layOut.delegate = self
        }
        self.myCollectionView.delegate = self
        self.myCollectionView.dataSource = self
        self.myCollectionView.reloadData()
    }
}


