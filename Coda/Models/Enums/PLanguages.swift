//
//  Languages.swift
//  Coda
//
//  Created by Matoi on 31.10.2022.
//

import Foundation


enum PLanguages : String, CaseIterable {
    
    static var allLangs: [PLanguages.RawValue] {
        [self.cpp.rawValue, self.swift.rawValue, self.objc.rawValue, self.java.rawValue, self.python.rawValue, self.common.rawValue].sorted()
    }
    
    case cpp  = "C++"
    case swift  = "Swift"
    case objc  = "Objective-C"
    case java  = "Java"
    case python  = "Python"
    case common  = "C"
    
}
