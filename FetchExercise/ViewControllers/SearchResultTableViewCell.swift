//
//  SearchResultTableViewCell.swift
//  FetchExercise
//
//  Created by Hassan Khan.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var FavouriteUIImage: UIImageView!
    @IBOutlet weak var SearchResultUIImage: UIImageView!
    @IBOutlet weak var titleUILabel: UILabel!
    @IBOutlet weak var locationUILabel: UILabel!
    @IBOutlet weak var dateUILabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
