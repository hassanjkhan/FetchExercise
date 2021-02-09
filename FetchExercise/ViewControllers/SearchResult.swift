//
//  SearchResult.swift
//  FetchExercise
//
//  Created by Hassan Khan.
//

import Foundation
import UIKit

class SearchResult {
    
    //MARK: Properties
    
    var title: String
    var location: String
    var date: String
    var photoURL: String?
    
    //MARK: Initialization
    
    init?(title: String, location: String, date: String, photo: String) {
        
        // The name must not be empty
        guard !title.isEmpty else {
            return nil
        }

        // Initialize stored properties.
        self.title = title
        self.location = location
        self.date = date
        self.photoURL = photo
        
    }
    
    
}

