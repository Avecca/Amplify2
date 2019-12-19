//
//  UserInfoViewController.swift
//  Amplify2
//
//  Created by Hanna Astlind on 2019-12-18.
//  Copyright © 2019 Hanna Astlind. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSMobileClient

class UserInfoViewController: UIViewController, UITextFieldDelegate {
    
    var appSyncClient: AWSAppSyncClient?
    private var user: Person?
    
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var surNameTextView: UITextField!
    @IBOutlet weak var saveSuccessLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var saveChangesBtn: UIButton!
    
    var recievingPerson: Person?
    var recievingUserExist: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        firstNameTextView.delegate = self
        surNameTextView.delegate = self

        if recievingUserExist && recievingPerson != nil {
            user = recievingPerson
            displayCurrentUserInfo()
        }
        
        userImageView.image = #imageLiteral(resourceName: "genericUser")
        userImageView.makeRounded()
        saveSuccessLbl.isHidden = true
        // Do any additional setup after loading the view.
        
    }
    

    
    func displayCurrentUserInfo() {
        if user != nil {
            firstNameTextView.text = user?.name ?? ""
            surNameTextView.text = user?.surname ?? ""
        }
    }
    
    
    func updateUserInfo(id: GraphQLID ,name: String!, surname: String!){
        
        var mutationInput = UpdateUserInput(id: id)
        mutationInput.name = name
        mutationInput.surname = surname
        
        appSyncClient?.perform(mutation: UpdateUserMutation(input: mutationInput)){ (result, error) in
            
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred while updating user: \(error.localizedDescription )")
            }else if let resultError = result?.errors {
                print("Error UPDATING the userInfo on server: \(resultError)")
                return
            }else {
                print("Success Updating UserInformation")

                DispatchQueue.main.async {
                    self.saveSucessViewChanges()
                }
            }
        }
        
    }
    func createUserInfo(name : String!, surname : String!) {
        
         let mutationInput = CreateUserInput(name: name, surname: surname, languages: [])
         
         appSyncClient?.perform(mutation: CreateUserMutation(input: mutationInput)){ (result, error) in
             if let error = error as? AWSAppSyncClientError {
                 print("Error mutating Creating User: \(error.localizedDescription)")
             }
             if let resultError = result?.errors{
                 print("Error saving the USER to server trhough mutation: \(resultError)")
                 return
             }
             print("Mutation Creating User complete.")
             
             print("NEW ID = " + (result?.data?.createUser!.id)!)
             
            if(result?.data?.createUser?.id != nil){
                self.user = Person(id: (result?.data?.createUser!.id)!, name: (result?.data?.createUser!.name)!, surname: (result?.data?.createUser!.surname)!, languages: [])
                self.recievingUserExist = true
            }
            
             // because the mutation will not complete before the query is sent(asynchronus), do callback
             DispatchQueue.main.async {
                self.saveSucessViewChanges()
                }
             
         }
    }
    func saveSucessViewChanges(){
        self.saveSuccessLbl.isHidden = false
        self.saveChangesBtn.isHidden = true
        
    }
    
    @IBAction func saveChangesPressed(_ sender: Any) {
      if firstNameTextView.text != "" && surNameTextView.text != "" {
            if recievingUserExist {
                updateUserInfo(id: user!.id ,name: firstNameTextView.text, surname: surNameTextView.text)
            }else{
                createUserInfo(name: firstNameTextView.text, surname: surNameTextView.text)
            }
        }
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveChangesBtn.isHidden = false
    }

}

extension UIImageView {

    func makeRounded() {

        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
