//
//  FirestoreSortDescriptors.swift
//  Coda
//
//  Created by Matoi on 01.04.2023.
//

import SwiftUI

enum FirestoreSortDescriptor: String {
    
    case newest = "timeNewest"
    case oldest = "timeOldest"
    case moreStars = "moreStars"
    case lessStars = "lessStars"
    case mostCommented = "mostCommented"
    case leastCommented = "leastCommented"
    case mostViewed = "mostViewed"
    case leastViewed = "leastViewed"
    
}
