//
//  ProjectConstructorMain.swift
//  Coda
//
//  Created by Matoi on 01.02.2023.
//

import SwiftUI

struct ProjectConstructorMain: View {
    var body: some View {
        List {
            
        }
//        .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Project")
                        .robotoMono(.semibold, 18)
                }
            }
    }
}

struct ProjectConstructorMain_Previews: PreviewProvider {
    static var previews: some View {
        ProjectConstructorMain()
    }
}
