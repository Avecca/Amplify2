//
//  ViewController.swift
//  Amplify2
//
//  Created by Hanna Astlind on 2019-12-03.
//  Copyright © 2019 Hanna Astlind. All rights reserved.
//

import UIKit
import AWSAppSync

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    var appSyncClient: AWSAppSyncClient?
    var discard : Cancellable?
    var personList: [Person]?
    @IBOutlet weak var nameLbl: UITextField!
    @IBOutlet weak var nameTableView: UITableView!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var idTxtView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTableView.delegate = self
        nameTableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        subscribe()
        //runQuery()
        print(self.personList?.count as Any)
        nameTableView.reloadData()
        
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
        var pers = ""
        appSyncClient?.fetch(query: GetTodoQuery(id: id), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
             
             if error != nil{
                 print(error?.localizedDescription ?? "error fetching")
                 return
             }
             
             print("Fetch Specific Query complete")

            //result?.data?.getTodo?.snapshot {
            pers += (result?.data?.getTodo!.name)! + (result?.data?.getTodo!.description)!
           // pers += (result?.data?.getTodo!.description)!
            
            print(" ")
            print(pers)
            print(" ")
            
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
        
        do {
            discard = try appSyncClient?.subscribe(subscription: OnCreateTodoSubscription(), resultHandler: { (result, transaction, error) in
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

