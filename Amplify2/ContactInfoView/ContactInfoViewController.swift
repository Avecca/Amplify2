//
//  ContactInfoViewController.swift
//  Amplify2
//
//  Created by Hanna Astlind on 2019-12-19.
//  Copyright © 2019 Hanna Astlind. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSMobileClient

class ContactInfoViewController: UIViewController {
    
    var appSyncClient: AWSAppSyncClient?
    
    @IBOutlet weak var contactImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var removeContactBtn: UIBarButtonItem!
    
    var recievingLanguage: Language?
    var recievingUser: Person?
    //var recievingLanguage = Language()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactImgView.image = #imageLiteral(resourceName: "genericUser")
        contactImgView.makeRounded()
        
        if recievingLanguage != nil {
            displayContactInfo()
        }else{
            //TODO segue back to Contacts
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        // Do any additional setup after loading the view.
    }
    
    private func displayContactInfo(){
        nameLbl.text = recievingLanguage?.type
    }
    
    private func deleteContactFromUser(userId: GraphQLID, languageId: String){
        
        var mutationInput = UpdateUserInput(id: userId)
        
        //saves everything But the filtered Obj
        let languages = recievingUser?.languages?.filter(){ $0.id != languageId}
        
        var languageInputs: [CodeLanguageInput] = []
        
        if languages!.count > 0 {
            
            languages?.forEach{
                let language = CodeLanguageInput(id: $0.id
                    , type: $0.type!)
                languageInputs.append(language)
            }
            
        }
        
        mutationInput.languages = languageInputs
        
        appSyncClient?.perform(mutation: UpdateUserMutation(input: mutationInput)){(result,error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error mutating: \(error.localizedDescription)")
            }
            if let resultError = result?.errors{
                print("Error saving the item to server trhough mutation: \(resultError)")
                return
            }
            print("Mutation complete, language removed.")
            
            // because the mutation will not complete before the query is sent(asynchronus), do callback
            
           
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToContactsFromInfo", sender: self)
            }
            
        }
  
    }
    
    
    @IBAction func removeContactBtnPressed(_ sender: Any) {
        
        if recievingUser != nil && recievingLanguage != nil {
            
            deleteContactFromUser(userId: recievingUser!.id, languageId: recievingLanguage!.id)
            
        }else{
            return
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
