//
//  newOAuthVC.swift
//  fbAuth
//
//  Created by Rabeeh KP on 27/12/17.
//  Copyright © 2017 Rabeeh KP. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class newOAuthVC: UIViewController {
    
    
    
    
    //MARK: -Variables
    var cellFunction = CellFunction()
    var userPhotos:NSArray!
    var loading : Bool = false
    var arrayImage : [UIImage] = []
    var items = 0

    //MARK: -Outlets
    
    @IBOutlet weak var demoCollection: UICollectionView!
    
    @IBOutlet weak var fbLoginBtm: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: -Action
    
    
    @IBAction func fbLogin(_ sender: UIButton) {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile","email","user_photos"], from: self) { (result, err) in
            if err != nil{
                print("Custom fb login failed" , err ?? "")
                return
            }
            self.cellFunction.showEmailAddress()
            print(result?.token.tokenString)
            if let fetching = FBSDKAccessToken.current()
            {
               
            self.fetchListOfUserPhotos()
                
            }
            
        }
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
                self.userPhotos = image!
                if self.arrayImage.count != self.userPhotos.count{
                    for item in 0...(self.userPhotos.count - 1){
                        let res = self.userPhotos![item] as! NSDictionary
                        let userPhotoString = res.value(forKey: "picture") as! String
                        let imageUrl:URL = URL(string: userPhotoString)!
                        
                        DispatchQueue.global(qos: .userInitiated).async  {
                            
                            let imageData:Data = try! Data(contentsOf: imageUrl)
                            // Add photo to a cell as a subview
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData){
                                    self.arrayImage.append(image)
                                    
                                }
                            }
                        }
                    }
                }
                if self.userPhotos != nil{
                    self.navigation()
                }
            }
        })
        
    }
    
    func navigation(){
        let  storyboard =  UIStoryboard(name: "Main", bundle: nil)
        let  destination = storyboard.instantiateViewController(withIdentifier: "newOAuthImgShowVC") as! newOAuthImgShowVC
        destination.userPhoto = self.userPhotos
        destination.arrayImages = arrayImage
        self.present(destination, animated: true, completion: nil)
    }
}
