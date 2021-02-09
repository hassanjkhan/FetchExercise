//
//  SearchResultViewController.swift
//  FetchExercise
//
//  Created by Hassan Khan.
//

import UIKit
import SDWebImage

class SearchResultViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var searchResults: [SearchResult]!
    var extraSearchResults: [SearchResult]!
    var index: Int!
    var gameTitle: String!
    var photoURL: String!
    var datetime: String!
    var location: String!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if delegate.favourites[gameTitle] == true {
            favouriteButton.setImage(UIImage(named: "heart"), for: .normal)
        } else {
            favouriteButton.setImage(UIImage(named: "emptyheart"), for: .normal)
        }
        
        titleLabel.text = self.gameTitle
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
        
        resultImage?.sd_setImage(with: URL(string: photoURL!), placeholderImage: UIImage(named: "noImage"))
        resultImage?.layer.cornerRadius = resultImage.frame.size.width / 25
        resultImage?.clipsToBounds = true
        
        datetimeLabel.text = datetime
        locationLabel.text = location
        
    }
    
    func setResult(results: [SearchResult], extra: [SearchResult], index: Int) {
        searchResults = results
        extraSearchResults = extra
        self.index = index
        let result = results[index]
        gameTitle = result.title
        photoURL  = result.photoURL
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE, d MMM, yyyy h:mm a"
        
        let date = dateFormatterGet.date(from: result.date)
        
        datetime  = dateFormatterPrint.string(from: date!)
        location  = result.location
        
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SearchTableViewController = storyboard.instantiateViewController(identifier: "SearchTableViewController") as! SearchTableViewController
        SearchTableViewController.setResults(results: searchResults, extra: extraSearchResults)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(SearchTableViewController)
    }
    
    @IBAction func favouriteButtonAction(_ sender: Any) {
        
        if delegate.favourites[gameTitle ?? ""] == true {
            delegate.favourites[gameTitle ?? ""] = false
            favouriteButton.setImage(UIImage(named: "emptyheart"), for: .normal)
            
        } else {
            delegate.favourites[gameTitle ?? ""] = true
            favouriteButton.setImage(UIImage(named: "heart"), for: .normal)
        }
    }
    
}
