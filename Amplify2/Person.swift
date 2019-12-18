//
//  Person.swift
//  Amplify2
//
//  Created by Hanna Astlind on 2019-12-03.
//  Copyright © 2019 Hanna Astlind. All rights reserved.
//

import Foundation
import AWSAppSync
import AWSMobileClient

class Person {
    var id: GraphQLID!
    var name : String?
    var surname: String?
    var languages: [Language]?
    var languageCount: Int?
    
    init(id: GraphQLID, name: String, surname: String, languages: [Language]?) {
        self.id = id
        self.name = name
        self.surname = surname
        self.languages = languages
        
        self.languageCount = languages?.count
        
    }
}
