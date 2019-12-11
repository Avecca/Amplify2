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
    @IBOutlet weak var nameLbl: UITextField!
    @IBOutlet weak var nameTableView: UITableView!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var idTxtView: UITextField!
    @IBOutlet weak var userNameLbl: UILabel!
    
    @IBOutlet weak var signINStateBtn: UIButton!
    
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
                        DispatchQueue.main.async {
                            self.signINStateBtn.titleLabel?.text = "Log Out"
                            self.userNameLbl.text = AWSMobileClient.default().username
                            self.runQuery()
                    }
                case .signedOut:
                    
                    AWSMobileClient.default().showSignIn(navigationController: self.navigationController!,
                        signInUIOptions: SignInUIOptions(canCancel: false, logoImage: #imageLiteral(resourceName: "Logo")),{ (userState, error) in
                        if let signInState = userState {
                            
                            print("Sign in flow completed: \(signInState)")
                            DispatchQueue.main.async {
                                self.signINStateBtn.titleLabel?.text = "Log Out"
                                self.userNameLbl.text = AWSMobileClient.default().username
                                self.runQuery()
                            }
                            }else if let error = error {
                                print("error logging in: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.signINStateBtn.titleLabel?.text = "Log In"
                                self.userNameLbl.text = ""
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
    
    @IBAction func logOutPressed(_ sender: Any) {
        
        AWSMobileClient.default().signOut()
        
        
        do {
            try appSyncClient?.clearCaches()
            
            DispatchQueue.main.async {
                
                    self.signInState()
                
            }
        } catch let err  {
            print(err.localizedDescription)
        }
        
        

    }
    
    @IBAction func logOutBtnPressed(_ sender: Any) {
        AWSMobileClient.default().signOut()
        
        
        do {
            try appSyncClient?.clearCaches()
        } catch let err  {
            print(err.localizedDescription)
        }
        
        
        DispatchQueue.main.async {
            
                self.signInState()
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
        
        runMutation(name: nameTxt)
        
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
    
    func runMutation(name: String) {
        
        let mutationInput = CreateTodoInput(name: name, description: "RTN_" + name)
        
        appSyncClient?.perform(mutation: CreateTodoMutation(input: mutationInput)){ (result, error) in
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
        let mutationInput = DeleteTodoInput(id: id)
        
        appSyncClient?.perform(mutation: DeleteTodoMutation(input: mutationInput)) {
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
        var mutationInput = UpdateTodoInput(id: id)
       // mutationInput.name = nameLbl.text ?? "forgot"
        mutationInput.description = nameLbl.text ?? "forgot"
        appSyncClient?.perform(mutation: UpdateTodoMutation(input: mutationInput)) { (result, error) in
            
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
        appSyncClient?.fetch(query: GetTodoQuery(id: id), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
             
             if error != nil{
                 print(error?.localizedDescription ?? "error fetching")
                 return
             }
             
             print("Fetch Specific Query complete")
            var pers = ""
            //result?.data?.getTodo?.snapshot {
            if(result != nil){
                
                pers =  ((result?.data?.getTodo!.description) ?? "ntfound")
                // pers += (result?.data?.getTodo!.description)!
            
                print(" ")
                print(pers)
                print(" ")
            }
            
            self.infoLbl.text =  pers
        }

           // [($0?.name)!] = ($0?.description)!
        //871f2c0b-e9dc-440d-8a71-593452abaa34
    }
    
             

    
    func runQuery() {
        
        print("ENTERING runQuery")
    
        
        appSyncClient?.fetch(query: ListTodosQuery(), cachePolicy: .fetchIgnoringCacheData) { (result, error) in
            //fetchIgnoringCacheData, returnCacheDataAndFetch
            if error != nil{
                print(error?.localizedDescription ?? "error fetching")
                return
            }
            
            print("Fetch Query complete")
            self.personList = []
//            let no = result?.data?.listTodos?.items?.count
//            let nostring = no
//            print("listTodo count: \(String(describing: nostring))")
            result?.data?.listTodos?.items?.forEach {
                print(($0?.name)! + " " + ($0?.description)!)
                let pers = Person(name: ($0?.name)!, desc:(($0?.description)!) )
                self.personList?.append(pers)
               // [($0?.name)!] = ($0?.description)!
            }
            
            print(self.personList?.count as Any)
            self.nameTableView.reloadData()
            print(" ")
            
            
        }
    }
    
    
    
    //realtime subscription to data
    func subscribe() {
        //TODO OWNER
        do {
            discard = try appSyncClient?.subscribe(subscription: OnCreateTodoSubscription(owner: AWSMobileClient.default().identityId!), resultHandler: { (result, transaction, error) in
                if let result = result{
                    print("CreateTodo sub data: " + result.data!.onCreateTodo!.name + " " + result.data!.onCreateTodo!.description!)
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
        return personList?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = nameTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NameTableViewCell
         
         let cellIndex = indexPath.item
         //nameclick.tag = cellindex
         
        
        cell.configCell(name: personList![cellIndex].name!, description: personList![cellIndex].description!)

         cell.nameLbl.tag = cellIndex
         
         
         return cell
    }
        

}

