//
//  Extensions.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import Foundation


extension NSError : Identifiable {
    public var id: Int { code }
}
