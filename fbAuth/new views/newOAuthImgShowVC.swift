//
//  newOAuthImgShowVC.swift
//  fbAuth
//
//  Created by Rabeeh KP on 27/12/17.
//  Copyright © 2017 Rabeeh KP. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class newOAuthImgShowVC: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource {
    
    //MARK: -Variables
    var userPhoto : NSArray!
    var arrayImages : [UIImage] = []
    var imgresult : [UIImage] = []
    var clicked : Bool!
    var items = 0
    //MARK: - outlets
    @IBOutlet weak var logOutFbBtn: UIButton!
    @IBOutlet weak var myCollectionView: UICollectionView!
    //MARK: -View methord
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkImg()
        clicked = false
        if userPhoto == nil{
        myCollectionView.reloadData()
        }
       
    }
    override func viewWillAppear(_ animated: Bool) {
        if userPhoto == nil{
            myCollectionView.reloadData()
        }
    }
    //MARK: -Action - fbLogout
    @IBAction func fbLogout(_ sender: UIButton) {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        clicked = true
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: -CollectionView DataSource
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
        myCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! fbImageShowingCell
        if clicked == true{
            myCell.fbImgShowingView.image = nil
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
            
                myCell.fbImgShowingView.image = image
//                myCell.addSubview(myCell.fbImgShowingView)
                                    if self.arrayImages.count != self.userPhoto.count{
                                    self.arrayImages.append(image)
                                    }
                                }
                            }
             }
        }
        return myCell
    }
    
    //MARK: -Fetching Function
    
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
                //image get
            }
        })
    }
    func checkImg(){
        if self.imgresult.count != self.userPhoto.count{
            for item in 0...(userPhoto.count - 1){
                let res = self.userPhoto![item] as! NSDictionary
                let userPhotoString = res.value(forKey: "picture") as! String
                let imageUrl:URL = URL(string: userPhotoString)!
                
                DispatchQueue.global(qos: .userInitiated).async  {
                    
                    let imageData:Data = try! Data(contentsOf: imageUrl)
                    // Add photo to a cell as a subview
                    DispatchQueue.main.async {
                        if let image = UIImage(data: imageData){
                            self.imgresult.append(image)
                            self.myCollectionView.delegate = self
                            self.myCollectionView.dataSource = self
                        }
                    }
                }
            }
        }
    }
}
