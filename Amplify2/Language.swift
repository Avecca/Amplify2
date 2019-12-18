//
//  Language.swift
//  Amplify2
//
//  Created by Hanna Astlind on 2019-12-12.
//  Copyright © 2019 Hanna Astlind. All rights reserved.
//

import Foundation
import AWSAppSync

class Language {
    var id: String! //GraphQLID!
    var type : String?
    
    init(type: String, id: String!) {   //GraphQLID
        self.type = type
        self.id = id
        
    }
}
