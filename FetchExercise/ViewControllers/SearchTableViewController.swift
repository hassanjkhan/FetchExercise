//
//  SearchTableViewController.swift
//  FetchExercise
//
//  Created by Hassan Khan.
//

import UIKit
import SGAPI
import SDWebImage


class SearchTableViewController: UITableViewController, UITextFieldDelegate{
    
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    private var currentPage: Int!
    var searchResults = [SearchResult]()
    var extrasearchResults = [SearchResult]()
    var callsTried: Int!
    var resultDictionary: [String: String] = [:]
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPage = 1
        callsTried = 0
        searchTextField.addTarget(self, action: #selector(SearchTableViewController.textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.delegate = self
        searchTextField.text = delegate.currentSearch
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchResults.removeAll()
        extrasearchResults.removeAll()
        currentPage = 1
        callsTried = 1
        resultDictionary.removeAll()
        fetchEvents(textField: searchTextField)
        
    }
    
    func setResults(results: [SearchResult], extra: [SearchResult]){
        searchResults = results
        extrasearchResults = extra
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SearchResultTableViewCell .")
        }
        
        if(searchResults.count > indexPath.row){
            let result = searchResults[indexPath.row]
            
            if delegate.favourites[result.title] == true {
                cell.FavouriteUIImage.alpha = 1
            } else {
                cell.FavouriteUIImage.alpha = 0
            }
            
            cell.SearchResultUIImage.sd_setImage(with: URL(string: result.photoURL!), placeholderImage: UIImage(named: "noImage"))
            cell.SearchResultUIImage.layer.cornerRadius = cell.SearchResultUIImage.frame.size.width / 7
            cell.SearchResultUIImage.clipsToBounds = true
            
            cell.titleUILabel.text = result.title
            cell.titleUILabel.font = UIFont.boldSystemFont(ofSize: 19.0)
            
            cell.locationUILabel.text = result.location
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "EEEE, d MMM, yyyy h:mm a"
            
            let date = dateFormatterGet.date(from: result.date)
            
            cell.dateUILabel.text = dateFormatterPrint.string(from: date!)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SearchResultViewController = storyboard.instantiateViewController(identifier: "SearchResultViewController") as! SearchResultViewController
        SearchResultViewController.setResult(results: searchResults, extra: extrasearchResults, index: indexPath.row)
        delegate.currentSearch = searchTextField.text ?? ""
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(SearchResultViewController)
        
    }
    
    struct Events: Codable {
        let events: [Event]
        
    }
    struct Event: Codable {
        let title: String?
        let datetime_utc: String?
        let venue: Venue?
        let performers: [Performer]
    }
    
    struct Venue: Codable {
        let state: String?
        let city: String?
    }
    struct Performer: Codable {
        let image: String?
    }
    
    func fetchEvents(textField: UITextField) {
        let url = URL(string: "https://api.seatgeek.com/2/events?per_page=40&page=" + String(currentPage) + "&client_id=MjE1MjM3MzF8MTYxMjE1NzcxNS4zNTI0NDQ2")!
        let maxResultsFound = self.searchResults.count + 5
        URLSession.shared.dataTask(with: url, completionHandler: { [self] data, response, error in
            guard let data=data, error == nil else{
                print("Error with fetching events:")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                //print("Error with the response, unexpected status code: \(response)")
                return
            }
            
            var event: Events?
            
            do  {
                event = try JSONDecoder().decode(Events.self, from: data)
            }
            catch {
                print("failed to convert to JSON \(error.localizedDescription)")
            }
            
            guard let json = event  else {
                return
            }
            
            for event in json.events {
                
                let location = (event.venue?.city)! + ", " + (event.venue?.state)!
                let performers = event.performers[0]
                DispatchQueue.main.async {
                    if (location.lowercased()).contains(textField.text!.lowercased()) || (event.title!.lowercased()).contains(textField.text!.lowercased())
                        &&
                        (self.containsResult(title: event.title!, date: event.datetime_utc!) == false)
                    {
                        
                        self.generateKey(title: event.title!, date: event.datetime_utc!)
                        
                        let currentResult = SearchResult(title: event.title!,
                                                         location: location,
                                                         date: event.datetime_utc!,
                                                         photo: performers.image ?? "")
                        
                        if self.searchResults.count < maxResultsFound {
                            if !self.searchResults.contains(where: { $0.title == currentResult!.title}){
                                self.searchResults.append(currentResult!)
                            }
                            
                        } else {
                            self.extrasearchResults.append(currentResult!)
                        }
                        
                        
                    }
                }
                
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.callsTried = 0
                self.currentPage += 1
                
            }
            
            
        }
        ).resume()
    }
    
    
    func generateKey(title: String, date: String){
        resultDictionary[title] = date
    }
    
    func containsResult(title: String, date: String) -> Bool {
        let keyExists = resultDictionary[title] != nil
        if keyExists {
            if resultDictionary[title] != nil {
                return true
            }
        }
        return false
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if extrasearchResults.isEmpty{
                fetchEvents(textField: searchTextField)
            } else {
                var i = 5
                for res in extrasearchResults {
                    let contains = resultDictionary[res.title] != nil
                    if !contains {
                        searchResults.append(res)
                        i = i - 1
                        if (i <= 0){
                            return
                        }
                    }
                    
                    extrasearchResults.remove(at: 0)
                    
                }
                
            }
            
        }
        
    }
    @IBAction func cancelButton(_ sender: Any) {
        searchTextField.text = ""
        searchResults.removeAll()
        extrasearchResults.removeAll()
        tableView.reloadData()
        currentPage = 1
        callsTried = 0
        resultDictionary.removeAll()
        
    }
}

