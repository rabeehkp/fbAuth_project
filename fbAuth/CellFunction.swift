//
//  CellFunction.swift
//  fbAuth
//
//  Created by Rabeeh KP on 21/12/17.
//  Copyright © 2017 Rabeeh KP. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class CellFunction: NSObject {
    
    func showEmailAddress(){
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else{ return}
        let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                print("some thing went wrong with fb user:", error)
                return
            }
            print("successfully loged iin with our user:", user ?? "")
        })
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, name , email"]).start { (connection, result, err) in
            if err != nil{
                print("failed to start graph request:", err ?? "")
                return
            }
            print(result ?? "")
        }
    }
    
    func fbsdkLogin(vcSelf:UIViewController){
        var results = String()
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile","user_photos"], from: vcSelf) { (result, err) in
            if err != nil{
                print("Custom fb login failed" , err ?? "")
                return
            }
            results = (result?.token.tokenString)!
        }
        print(results)
    }
    
    func callDelegate(myCollectionView: UICollectionView, vcSelf : UIViewController){
        if let layOut = myCollectionView.collectionViewLayout as? customImgLayout
                    {
                        layOut.delegate = vcSelf as! CustomLayOutDelegate
                    }
                }

//    func getImage(userPhotos: NSArray?)-> [UIImage]{
//        let indexPath = IndexPath(row: 0, section: 0)
//        var images : [UIImage] = []
//    let userPhotoObject = userPhotos![indexPath.row] as! NSDictionary
//    let userPhotoUrlString = userPhotoObject.value(forKey: "picture") as! String
//    let imageUrl:URL = URL(string: userPhotoUrlString)!
//    
//    DispatchQueue.global(qos: .userInitiated).async  {
//    
//    let imageData:Data = try! Data(contentsOf: imageUrl)
//    // Add photo to a cell as a subview
//    DispatchQueue.main.async {
//    if let image = UIImage(data: imageData){
//        images[0] = image
//        }
//    }
//    }
//        return images
//        }
}
