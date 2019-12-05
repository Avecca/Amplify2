//
//  NameTableViewCell.swift
//  Amplify2
//
//  Created by Hanna Astlind on 2019-12-03.
//  Copyright © 2019 Hanna Astlind. All rights reserved.
//

import UIKit

class NameTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var descLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    func configCell(name: String, description: String){  //pet: Pet //Pet
        if name != "" {

          
            nameLbl?.text = name
            descLbl.text = description
            
        }
        
    }

}
