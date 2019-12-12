//
//  ViewController.swift
//  Amplify2
//
//  Created by Hanna Astlind on 2019-12-03.
//  Copyright © 2019 Hanna Astlind. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSMobileClient

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    var appSyncClient: AWSAppSyncClient?
    var discard : Cancellable?
    var personList: [Person]?
    var languagesList : [Language]?
    var userInfoExists : Bool = false
    @IBOutlet weak var nameLbl: UITextField!
    @IBOutlet weak var nameTableView: UITableView!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var idTxtView: UITextField!
    
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var signINStateBtn: UIButton!
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var userSurnameLbl: UILabel!
    @IBOutlet weak var userNameTxtField: UITextField!
    @IBOutlet weak var userSurnameTxtField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //sign in auth user
        signInState()
        
        nameTableView.delegate = self
        nameTableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        //subscribe()
       // runQuery()
        print(self.personList?.count as Any)
        //nameTableView.reloadData()
        
    }
    
    func signInState(){
        

        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                print("UserState: \(userState.rawValue)")
                //self.signInState(userState: userState)
                
                switch(userState){
                case .signedIn:
                    print("Signed in already")
                    self.signINStateBtn.setTitle("Log Out", for: .normal)
                    self.userNameBtn.setTitle(AWSMobileClient.default().username, for: .normal )
                        DispatchQueue.main.async {
                            print("Signed in already in queue")

                            self.checkUser()
                            self.runQuery()
                    }
                case .signedOut:
                    
                    AWSMobileClient.default().showSignIn(navigationController: self.navigationController!,
                        signInUIOptions: SignInUIOptions(canCancel: false, logoImage: #imageLiteral(resourceName: "Logo")),{ (userState, error) in
                        if let signInState = userState {
                            
                            print("Sign in flow completed: \(signInState)")
                            self.signINStateBtn.setTitle("Log Out", for: .normal)
                            self.userNameBtn.setTitle(AWSMobileClient.default().username, for:  .normal)
                            DispatchQueue.main.async {

                                self.checkUser()
                                self.runQuery()
                            }
                            }else if let error = error {
                                print("error logging in: \(error.localizedDescription)")
                                DispatchQueue.main.async {
                                    self.signINStateBtn.setTitle("Log In", for: .normal)
                                    self.userNameBtn.setTitle("", for: .normal)
                                }
                            }
                        
                        })
                    
                default:
                    AWSMobileClient.default().signOut()
                }
            } else if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }

    }
    @IBAction func userPressed(_ sender: Any) {
        
        let name = userNameTxtField.text ?? "newname"
        let surname =  userSurnameTxtField.text ?? "newsurname"
        
        if personList!.count > 0 {
            let id =  personList![0].id
            updateUser(id: id!, name: name, surname: surname)
        } else{
            createUserInfo(name: name, surname: surname)
        }
        
        
    }
    
    func updateUser(id: GraphQLID, name: String , surname: String){
        
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
                print("Success Updating UserINformation")
                self.userNameTxtField.text = ""
                self.userSurnameTxtField.text = ""
                DispatchQueue.main.async {
            
                    self.checkUser()
                }
            }
            
            
        }
        
        
        
    }
    
    func createUserInfo(name: String, surname: String) {
        
        let mutationInput = CreateUserInput(name: name, surname: surname)
        
        appSyncClient?.perform(mutation: CreateUserMutation(input: mutationInput)){ (result, error) in
           // self.runQuery()
            if let error = error as? AWSAppSyncClientError {
                print("Error mutating Creating User: \(error.localizedDescription)")
            }
            if let resultError = result?.errors{
                print("Error saving the USER to server trhough mutation: \(resultError)")
                return
            }
            print("Mutation Creating User complete.")
            
            self.userNameTxtField.text = ""
            self.userSurnameTxtField.text = ""
            
            // because the mutation will not complete before the query is sent(asynchronus), do callback
            DispatchQueue.main.async {
           
                   self.checkUser()
               }
            
        }
        
    }
    
    func checkUser(){
    
        print("Aboiut to check if userinfo exists")
        appSyncClient?.fetch(query: ListUsersQuery(), cachePolicy: .returnCacheDataAndFetch){ (result, error) in
            
            if error != nil{
                print(error?.localizedDescription ?? "error fetching")
                return
            }
            
            print("Fetching Userinfo")
            self.personList = []
            
            result?.data?.listUsers?.items?.forEach {
            print(($0?.name)! + " " + ($0?.surname)!)
                let pers = Person(id: ($0?.id)!, name: ($0?.name)!, surname:(($0?.surname)!) )
            self.personList?.append(pers)
            }
            
            if(self.personList!.count > 0){
                
                self.usernameLbl.text = self.personList![0].name
                self.userSurnameLbl.text = self.personList![0].surname
                
            } else if (self.personList!.count < 1){
                self.usernameLbl.text = "name"
                self.userSurnameLbl.text = "surname"
            }
 
        }
   
    }
    
//    @IBAction func logOutPressed(_ sender: Any) {
//
//        AWSMobileClient.default().signOut()
//
//
//        do {
//
//            try appSyncClient?.clearCaches()
//
//            DispatchQueue.main.async {
//
//                    self.signInState()
//
//            }
//        } catch let err  {
//            print(err.localizedDescription)
//        }
//
//
//
//    }
    
    @IBAction func logOutBtnPressed(_ sender: Any) {
        AWSMobileClient.default().signOut()
        
        
        do {
            personList = []
            languagesList = []
            usernameLbl.text = "name"
            userSurnameLbl.text = "surname"
            nameLbl.text = ""
            idTxtView.text = ""
            try appSyncClient?.clearCaches()
        } catch let err  {
            print(err.localizedDescription)
        }
        
        
        DispatchQueue.main.async {
            
                self.signInState()
        }
    }
    

    
    @IBAction func infoBtnPressed(_ sender: Any) {
        self.infoLbl.text = ""
        print("TRYING TO Fetch Specific")

        if idTxtView.text!.count < 1 {
            return
        }else {
            let idTxt = idTxtView.text
            runSpecificQuery(id: idTxt!)
        }
        
        //871f2c0b-e9dc-440d-8a71-593452abaa34
        
    }
    @IBAction func saveName(_ sender: Any) {
        
        print("TRYING TO SAVE")
        let nameTxt = nameLbl.text ?? "testname"
        
        runMutation(codeName: nameTxt)
        
        nameLbl.text = ""
        
    }
    @IBAction func deleteBtnPressed(_ sender: Any) {
        
        print("TRYING TO DELETE")
        if idTxtView.text!.count < 1 {
            return
        }else {
            let idTxt = idTxtView.text
            runDeleteSpecific(id: idTxt!)
        }
    }
    
    @IBAction func updateBtnPressed(_ sender: Any) {
        print("TRYING TO UPDATE")
        
        if idTxtView.text!.count < 1 {
            return
        }else {
            let idTxt = idTxtView.text
            runUpdateSpecific(id: idTxt!)
        }
        
        
    }
    @IBAction func printNames(_ sender: Any) {
        runQuery()
    }
    
    func runMutation(codeName: String) {
        
        let mutationInput = CreateCodeLanguageInput(type: codeName)
        
        appSyncClient?.perform(mutation: CreateCodeLanguageMutation(input: mutationInput)){ (result, error) in
           // self.runQuery()
            if let error = error as? AWSAppSyncClientError {
                print("Error mutating: \(error.localizedDescription)")
            }
            if let resultError = result?.errors{
                print("Error saving the item to server trhough mutation: \(resultError)")
                return
            }
            print("Mutation complete.")
            
            // because the mutation will not complete before the query is sent(asynchronus), do callback
           // self.runQuery()
            
        }
    }
    
    func runDeleteSpecific( id : String){
        let mutationInput = DeleteCodeLanguageInput(id: id)
        
        appSyncClient?.perform(mutation: DeleteCodeLanguageMutation(input: mutationInput)) {
            (result, error) in
            
            if let error = error as? AWSAppSyncClientError {
                print("Error mutating: \(error.localizedDescription)")
            }
            if let resultError = result?.errors{
                print("Error DELETING the item from server through mutation: \(resultError)")
                return
            }else{
               print("Delete Mutation complete.")
                self.runQuery()
            }
            
        }
    }
    func runUpdateSpecific(id: String){
        var mutationInput = UpdateCodeLanguageInput(id: id) //UpdateCodeLanguageInput(id: id)
       // mutationInput.name = nameLbl.text ?? "forgot"
        mutationInput.type = nameLbl.text ?? "forgot"
        appSyncClient?.perform(mutation: UpdateCodeLanguageMutation(input: mutationInput)) { (result, error) in
            
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }else if let resultError = result?.errors {
                print("Error UPDATING the item on server: \(resultError)")
                return
            }else {
                print("Success Updating Data")
                self.runQuery()
            }
        }
        
    }
    
     func runSpecificQuery( id: String){
         print("Entering specific query")
        //var pers = ""
        appSyncClient?.fetch(query: GetCodeLanguageQuery(id: id), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
             
             if error != nil{
                 print(error?.localizedDescription ?? "error fetching")
                 return
             }
             
             print("Fetch Specific Query complete")
            var codeType = ""
            //result?.data?.getTodo?.snapshot {
            if(result != nil){
                
                codeType = result?.data?.getCodeLanguage?.type ?? "not found"
//                    (((result?.data?.getUser!.name) ?? "ntfound") + " " + (result?.data?.getUser!.surname ?? "surname") )
                // pers += (result?.data?.getTodo!.description)!
            
                print(" ")
                print(codeType)
                print(" ")
            }
            
            self.infoLbl.text =  codeType
        }

           // [($0?.name)!] = ($0?.description)!
        //871f2c0b-e9dc-440d-8a71-593452abaa34
    }
    
             

    
    func runQuery() {
        
        print("ENTERING runQuery")
    
        
        appSyncClient?.fetch(query: ListCodeLanguagesQuery(), cachePolicy: .fetchIgnoringCacheData) { (result, error) in
            //fetchIgnoringCacheData, returnCacheDataAndFetch
            if error != nil{
                print(error?.localizedDescription ?? "error fetching")
                return
            }
            
            print("Fetch Query complete")
            self.languagesList = []
//            let no = result?.data?.listTodos?.items?.count
//            let nostring = no
//            print("listTodo count: \(String(describing: nostring))")
            result?.data?.listCodeLanguages?.items?.forEach {
                print(($0?.type)!)
                let codeType = Language(type: ($0?.type)! )
                self.languagesList?.append(codeType)
               // [($0?.name)!] = ($0?.description)!
            }
            
            print(self.languagesList?.count as Any)
            self.nameTableView.reloadData()
            print(" ")
            
            
        }
    }
    
    
    
    //realtime subscription to data
    func subscribe() {
        //TODO OWNER
        do {
            discard = try appSyncClient?.subscribe(subscription: OnCreateCodeLanguageSubscription(owner: AWSMobileClient.default().identityId!), resultHandler: { (result, transaction, error) in
                if let result = result{
                    print("CreateLanguage sub data: " + result.data!.onCreateCodeLanguage!.type) /*result.data!.onCreateUser!.name + " " + result.data!.onCreateUser!.surname!)*/
                    self.runQuery()
                    //self.nameTableView.reloadData()
                } else if let error = error{
                    print(error.localizedDescription)
                }
            })
            print("Subbing to CreateToDo Mutations")
            

        } catch  {
            print("Error when trying to subscribe")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languagesList?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = nameTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NameTableViewCell
         
         let cellIndex = indexPath.item
         //nameclick.tag = cellindex
         
        
//        cell.configCell(name: personList![cellIndex].name!, description: personList![cellIndex].description!)
        
        cell.configCell(language: languagesList![cellIndex].type!)

         cell.descLbl.tag = cellIndex
         
         
         return cell
    }
        

}

 //                    DispatchQueue.main.async {
    //                        self.signInStateLbl.text = "Logged Out"
    //                    }
    
    //                            if(error == nil){       //Successful signin
    //                                DispatchQueue.main.async {
    //                                    self.signInStateLbl.text = "Logged In"
    //                                }
    //                            }
//
//    func signInStateWithSignUpPage(){
//
//        AWSMobileClient.default().signUp(username: "your_username",
//                                                password: "Abc@123!",
//                                                userAttributes: ["email":"john@doe.com", "phone_number": "+1973123456"]) { (signUpResult, error) in
//            if let signUpResult = signUpResult {
//                switch(signUpResult.signUpConfirmationState) {
//                case .confirmed:
//                    print("User is signed up and confirmed.")
//                case .unconfirmed:
//                    print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
//                case .unknown:
//                    print("Unexpected case")
//                }
//            } else if let error = error {
//                if let error = error as? AWSMobileClientError {
//                    switch(error) {
//                    case .usernameExists(let message):
//                        print(message)
//                    default:
//                        break
//                    }
//                }
//                print("\(error.localizedDescription)")
//            }
//        }
//
//
//    }

//
//    func confirmSignUp() {
//        AWSMobileClient.default().confirmSignUp(username: "your_username", confirmationCode: signUpCodeTextField.text!) { (signUpResult, error) in
//            if let signUpResult = signUpResult {
//                switch(signUpResult.signUpConfirmationState) {
//                case .confirmed:
//                    print("User is signed up and confirmed.")
//                case .unconfirmed:
//                    print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
//                case .unknown:
//                    print("Unexpected case")
//                }
//            } else if let error = error {
//                print("\(error.localizedDescription)")
//            }
//        }
//    }


//    func resendConformSignup(){
//        AWSMobileClient.default().resendSignUpCode(username: "your_username", completionHandler: { (result, error) in
//            if let signUpResult = result {
//                print("A verification code has been sent via \(signUpResult.codeDeliveryDetails!.deliveryMedium) at \(signUpResult.codeDeliveryDetails!.destination!)")
//            } else if let error = error {
//                print("\(error.localizedDescription)")
//            }
//        })
//
//    }
    
    
    
//    func signIn(){
//        AWSMobileClient.default().signIn(username: "your_username", password: "Abc@123!") { (signInResult, error) in
//            if let error = error  {
//                print("\(error.localizedDescription)")
//            } else if let signInResult = signInResult {
//                switch (signInResult.signInState) {
//                case .signedIn:
//                    print("User is signed in.")
//                case .smsMFA:
//                    print("SMS message sent to \(signInResult.codeDetails!.destination!)")
//                default:
//                    print("Sign In needs info which is not et supported.")
//                }
//            }
//        }
//
//    }

