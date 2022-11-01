//
//  Project.swift
//  Coda
//
//  Created by Matoi on 31.10.2022.
//

import Foundation


struct Project: Identifiable {
    var id : UUID = UUID()
    var image : String
    var name : String
    var description : String
}
