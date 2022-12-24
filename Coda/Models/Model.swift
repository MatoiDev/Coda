//
//  Model.swift
//  Coda
//
//  Created by Matoi on 20.12.2022.
//

import SwiftUI

class Model: ObservableObject {
    func reloadView() {
        objectWillChange.send()
    }
}
