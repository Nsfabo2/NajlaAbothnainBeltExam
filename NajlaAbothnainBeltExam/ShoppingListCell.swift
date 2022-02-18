//
//  ShoppingListCell.swift
//  NajlaAbothnainBeltExam
//
//  Created by Najla on 15/01/2022.
//

import UIKit

class ShoppingListCell: UITableViewCell {
    
    @IBOutlet weak var ItemTitle: UILabel!
    @IBOutlet weak var ItemSubTitle: UILabel!
    @IBOutlet weak var ItemCompleted: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
