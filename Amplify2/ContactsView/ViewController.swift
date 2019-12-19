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
    //TODO SPara Languagelist[0] som en person
    var languagesList : [Language]?
    var userInfoExists : Bool = false
    @IBOutlet weak var nameLbl: UITextField!
    @IBOutlet weak var nameTableView: UITableView!
    
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var userLogStateBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    
    let segueToUserInfo = "segueToUserInfo"
    
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //TODO if from UserInfo and changes made only fetch those
        if AWSMobileClient.default().isSignedIn {
            DispatchQueue.main.async {
                    print("Signed in fetching info")

                    self.checkUser()
                    //self.runQuery()
            }
        }
    }
    
    func signInState(){

        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                print("UserState: \(userState.rawValue)")
                //self.signInState(userState: userState)
                
                switch(userState){
                case .signedIn:
                    print("Signed in already")
                    self.userLogStateBarBtn.title = "Log Out" // setTitle("Log Out", for: .normal)
                    self.userNameBtn.setTitle(AWSMobileClient.default().username, for: .normal )
                        DispatchQueue.main.async {
                            print("Signed in already in queue")

                            //self.checkUser()
                            //self.runQuery()
                    }
                case .signedOut:
                    //TODO clear cache
                    AWSMobileClient.default().showSignIn(navigationController: self.navigationController!,
                        signInUIOptions: SignInUIOptions(canCancel: false, logoImage: #imageLiteral(resourceName: "Logo")),{ (userState, error) in
                        if let signInState = userState {
                            
                            print("Sign in flow completed: \(signInState)")
                            self.userLogStateBarBtn.title = "Log Out" //.setTitle("Log Out", for: .normal)
                            self.userNameBtn.setTitle(AWSMobileClient.default().username, for:  .normal)
                            DispatchQueue.main.async {

                                self.checkUser()
                               // self.runQuery()
                            }
                            }else if let error = error {
                                print("error logging in: \(error.localizedDescription)")
                                DispatchQueue.main.async {
                                    self.userLogStateBarBtn.title = "Log In"//.setTitle("Log In", for: .normal)
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
        
        
        print("AuthUserNamePressed, nothing is suppsoed to happen atm")
//        let name = userNameTxtField.text ?? "newname"
//        let surname =  userSurnameTxtField.text ?? "newsurname"
//
//        if personList!.count > 0 {
//            let id =  personList![0].id
//            updateUser(id: id!, name: name, surname: surname)
//        } else{
//            createUserInfo(name: name, surname: surname)
//        }
        
        
    }
    
    
    func checkUser(){
    
        print("Aboiut to check if userinfo exists")
        appSyncClient?.fetch(query: ListUsersQuery(), cachePolicy: .returnCacheDataAndFetch){ (result, error) in
            
            if error != nil{
                print(error?.localizedDescription ?? "error fetching")
                return
            }
            print()
            print("Fetching Userinfo")
            self.personList = []
            
            result?.data?.listUsers?.items?.forEach {
            print(($0?.name)! + " " + ($0?.surname)!)
                var langList: [Language] = []
                $0?.languages?.forEach{
                    let lang = Language(type: $0!.type, id: $0!.id)
                    langList.append(lang)
                   // print(lang.id! + " and " + lang.type!)
                }

                
                //print("all lang: !")
                //print($0?.languages as Any)  //works
                
                let pers = Person(id: ($0?.id)!, name: ($0?.name)!, surname:($0?.surname)!, languages: langList )
               // print(pers.self)
                //print(langList.self)
                self.personList?.append(pers)

            }
            
            self.languagesList = []

            
            self.nameTableView.reloadData()
            
            if(self.personList!.count > 0){
                self.usernameLbl.text = self.personList![0].name! + " " + self.personList![0].surname!
                
                for lan in self.personList![0].languages! {
                    print(lan.id + " " + lan.type!)
                    self.languagesList?.append(lan)
                }
                
                self.nameTableView.reloadData()
                
            } else if (self.personList!.count < 1){
                self.usernameLbl.text = "Edit User to add a name"
            }
 
        }
   
    }
    
    
    @IBAction func userLogStateBarBtnPressed(_ sender: Any) {
        
        AWSMobileClient.default().signOut()
        
        do {
            personList = []
            languagesList = []
            usernameLbl.text = "Add a name in Edit User"
            nameLbl.text = ""
            //idTxtView.text = ""
            try appSyncClient?.clearCaches()
        } catch let err  {
            print(err.localizedDescription)
        }
        
        
        DispatchQueue.main.async {
            
                self.signInState()
        }
        
    }
    
    
    @IBAction func saveName(_ sender: Any) {
        
        print("TRYING TO SAVE")
        let nameTxt = nameLbl.text ?? "testname"
        let perID = personList![0].id!
        if perID != "" {
            addCodeLanguageMutation(id: perID, codeName:  nameTxt)
        }
        
        nameLbl.text = ""
        
    }
    @IBAction func deleteBtnPressed(_ sender: Any) {
        
        print("TRYING TO DELETE")
//        if idTxtView.text!.count < 1 {
//            return
//        }else {
//            let idTxt = idTxtView.text
//          //  runDeleteSpecific(id: idTxt!)
//        }
    }
    
    @IBAction func updateBtnPressed(_ sender: Any) {
        print("TRYING TO UPDATE")
//
//        if idTxtView.text!.count < 1 {
//            return
//        }else {
//            let idTxt = idTxtView.text
//           // runUpdateSpecific(id: idTxt!)
//        }
    }
    @IBAction func printNames(_ sender: Any) {
        fetchLanguagesFromUser()
       // runQuery()
    }
    
    func addCodeLanguageMutation(id: GraphQLID ,codeName: String) {
        
        var mutationInput = UpdateUserInput(id: id)
        
        var index = 0
        var oldLanguages: [CodeLanguageInput] = []

        if (languagesList!.count > 0 ){

            for language in languagesList! {
                let cl = CodeLanguageInput(id: language.id, type: language.type!)
                oldLanguages.append(cl)
                let x =  language.id // item.value(forKey: "index") as! String
                if  Int(x!)! > index {
                    index = Int(x!)!
                }
            }
        }

        index += 1
        
        let newLanguage = CodeLanguageInput(id: String(index), type: codeName)
        oldLanguages.append(newLanguage)
        
            
        mutationInput.languages = oldLanguages
        
        appSyncClient?.perform(mutation: UpdateUserMutation(input: mutationInput)){
            (result, error) in
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
        
        //[CodeLanguageInput(id: "1", type: codeName), CodeLanguageInput(id: "2", type: codeName + "2")] //[Language(type: "1", id: codeName)] //personList![0].languages?.append(<#T##newElement: Language##Language#>)
        
                
        //        var oldLanguages = [languagesList?.forEach{
        //            CodeLanguageInput(id: $0.id , type: $0.type!)
        //        }]
                
               // mutationInput.languages = oldLanguages.append(newLanguage)
        
                
                //appSyncClient?.perform(mutation: UpdateUserInput.)
                
        //        let mutationInput = CreateCodeLanguage(type: codeName)
        //
        //        var mI = UpdateUserInput(id: id)
        //
        //
        //
        //        let muI =  UserCodeLanguageInput(codeList: [CodeLanguageInput(type: codeName)])
        //
        //
        //       // let muIn = UpdateUserInput(id: id,  codeList: UserCodeLanguageInput(codeList: [CodeLanguageInput(type: codeName)]))

        //        mI.codeList?.append(CodeLanguageInput(type: codeName))
                
                //mI.codeList?.append(CodeLanguageInput(type: codeName))
                
                //appSyncClient?.perform(mutation:UpdateUserMutation)
         
                //id: id, codeList: muI
                
                //let mutationInput = CreateCodeLanguageInput(type: codeName)
        
        // let mutationInput = //CodeLanguageInput(type: codeName)
        
        // let mutaionInput = CodeLanguageInput(type: codeName)
       // var mutationInput = UpdateUserInpt(id: id)
        

//        appSyncClient?.perform(mutation: NewCodeLanguageMutation(type: codeName)){
//
//        }
        
        
        
        //mutationInput.codeList?.append(CodeLanguageInput(id: "3", type: codeName))
        //mutationInput.codeList?.append(CodeLanguageInput(id: "3", type: codeName))
            //[(CodeLanguageInput( id: "1", type: codeName)), (CodeLanguageInput( id: "2", type: codeName + "2")) ]
        //[(CodeLanguagesInput( id: "3", type: codeName)), (CodeLanguagesInput( id: "4", type: codeName + "2")) ]
        //.append(CodeLanguagesInput( id: "5", type: codeName))
//
//        let mutationInput = CreateCodeLanguagesInput(type: codeName)
        //CreateCodeLanguagesMutation
//        appSyncClient?.perform(mutation: UpdateUserMutation(input: mutationInput)){ (result, error) in
//           // self.runQuery()
//            if let error = error as? AWSAppSyncClientError {
//                print("Error mutating: \(error.localizedDescription)")
//            }
//            if let resultError = result?.errors{
//                print("Error saving the item to server trhough mutation: \(resultError)")
//                return
//            }
//            print("Mutation complete.")
//
//            // because the mutation will not complete before the query is sent(asynchronus), do callback
//           // self.runQuery()
//
//        }
    }
    
  /*  func runDeleteSpecific( id : String){
        let mutationInput = DeleteCodeLanguagesInput(id: id)
        
        appSyncClient?.perform(mutation: DeleteCodeLanguagesMutation(input: mutationInput)) {
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
    }*/
    
  /*  func runUpdateSpecific(id: String){
        var mutationInput = UpdateCodeLanguagesInput(id: id) //UpdateCodeLanguageInput(id: id)
       // mutationInput.name = nameLbl.text ?? "forgot"
        mutationInput.type = nameLbl.text ?? "forgot"
        appSyncClient?.perform(mutation: UpdateCodeLanguagesMutation(input: mutationInput)) { (result, error) in
            
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
        
    }*/
  
    //TODO not in use, only as example
     func runSpecificQuery( id: String){
         print("Entering specific query")
        //var pers = ""
        //GetCodeLanguagesQuery(id: id)
        appSyncClient?.fetch(query: GetUserQuery(id: id), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
             
             if error != nil{
                 print(error?.localizedDescription ?? "error fetching")
                 return
             }
             
             print("Fetch Specific Query complete")
            var codeType = ""
            //result?.data?.getTodo?.snapshot {
            if(result != nil){
                 //getCodeLanguages?.type
                codeType = result?.data?.getUser?.name ?? "not found"
//                    (((result?.data?.getUser!.name) ?? "ntfound") + " " + (result?.data?.getUser!.surname ?? "surname") )
                // pers += (result?.data?.getTodo!.description)!
            
                print(" ")
                print(codeType)
                print(" ")
            }
            
            //self.infoLbl.text =  codeType
        }

           // [($0?.name)!] = ($0?.description)!
        //871f2c0b-e9dc-440d-8a71-593452abaa34
    }
    
    
    func fetchLanguagesFromUser(){
        
        print("ENTERING fetchLanguagesFromUser ")
        
        if personList!.count > 0 {
 
            appSyncClient?.fetch(query:  GetUserQuery(id: personList![0].id), cachePolicy: .returnCacheDataAndFetch){ (result, error) in
                
                if error != nil{
                    print(error?.localizedDescription ?? "error fetching")
                    return
                }
                
                print("Fetch Specific Users Query complete")
                self.languagesList = []
                
                result?.data?.getUser?.languages!.forEach {
                    let lang = Language(type: $0!.type, id: $0!.id)
                    self.languagesList?.append(lang) //  languagesList.append(lang)
                       // print(lang.id! + " and " + lang.type!)
                    print("Updating Languagelist")
                }

                
                self.personList![0].languages = self.languagesList
                
                print(self.languagesList?.count as Any)
                self.nameTableView.reloadData()
                print(" ")
                
            }
        }
    }
             

    
 /*   func runQuery() {
        
        print("ENTERING runQuery")
    
        
        appSyncClient?.fetch(query: ListCodeLanguagessQuery(), cachePolicy: .fetchIgnoringCacheData) { (result, error) in
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
            result?.data?.listCodeLanguagess?.items?.forEach {
                print(($0?.type)!)
                let codeType = Language(type: ($0?.type)!, id: ($0?.id)!)
                self.languagesList?.append(codeType)
               // [($0?.name)!] = ($0?.description)!
            }
            
            
            print(self.languagesList?.count as Any)
            self.nameTableView.reloadData()
            print(" ")
            
            
        }
    } */
    
    
    
    //realtime subscription to data
 /*   func subscribe() {
        //TODO OWNER
        do {
            discard = try appSyncClient?.subscribe(subscription: OnCreateCodeLanguagesSubscription(owner: AWSMobileClient.default().identityId!), resultHandler: { (result, transaction, error) in
                if let result = result{
                    print("CreateLanguage sub data: " + result.data!.onCreateCodeLanguages!.type) /*result.data!.onCreateUser!.name + " " + result.data!.onCreateUser!.surname!)*/
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
        
    }*/
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if AWSMobileClient.default().isSignedIn {
            return languagesList?.count ?? 0 //personList![0].languageCount ?? 0
        } else {
            return 0
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = nameTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NameTableViewCell
         
         let cellIndex = indexPath.item
         //nameclick.tag = cellindex
         
        
//        cell.configCell(name: personList![cellIndex].name!, description: personList![cellIndex].description!)
        
        //let lang = self.personList![0].languages![cellIndex].type
        
        cell.configCell(language: languagesList![cellIndex].type! ) //languagesList![cellIndex].type!) //lang!

        cell.descLbl.tag = Int(languagesList![cellIndex].id)! // cellIndex
         
         
         return cell
    }
    
    
    @IBAction func prepareForUnwind(_ unwindSegue: UIStoryboardSegue) {
       // let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        print("In unwindsegue!!")
        if unwindSegue.identifier == "unwindToContacts" {
            
            //let sourceViewController = unwindSegue.source
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToUserInfo {
            let destinationVC = segue.destination as! UserInfoViewController
            if personList!.count > 0 {
                destinationVC.recievingUserExist = true
                destinationVC.recievingPerson = personList![0]
            } else{
                destinationVC.recievingUserExist = false
            }
        }
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
//                }sky
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

