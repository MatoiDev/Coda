//
//  SortDescriptorsPickerSheetView.swift
//  Coda
//
//  Created by Matoi on 03.04.2023.
//

import SwiftUI

struct SortDescriptorsPickerSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var descriptor: FirestoreSortDescriptor
    @State private var descritorSetter: FirestoreSortDescriptor = .newest
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        self.descritorSetter = .newest
                    } label: {
                        HStack {
                            Text("Newest")
                                .robotoMono(.semibold, 15)
                            Spacer()
                            if self.descritorSetter == .newest { Image(systemName: "checkmark").foregroundColor(Color("BackgroundColor2")) }
                            
                        }
                    }
                    Button {
                        self.descritorSetter = .oldest
                    } label: {
                        HStack {
                            Text("Oldest")
                                .robotoMono(.semibold, 15)
                            Spacer()
                            if self.descritorSetter == .oldest { Image(systemName: "checkmark").foregroundColor(Color("BackgroundColor2")) }
                            
                        }
                    }

                }
                
                Section {
                    Button {
                        self.descritorSetter = .moreStars
                    } label: {
                        HStack {
                            Text("More stars")
                                .robotoMono(.semibold, 15)
                            Spacer()
                            if self.descritorSetter == .moreStars { Image(systemName: "checkmark").foregroundColor(Color("BackgroundColor2")) }
                            
                        }
                    }
                    Button {
                        self.descritorSetter = .lessStars
                    } label: {
                        HStack {
                            Text("Less stars")
                                .robotoMono(.semibold, 15)
                            Spacer()
                            if self.descritorSetter == .lessStars { Image(systemName: "checkmark").foregroundColor(Color("BackgroundColor2")) }
                            
                        }
                    }

                }
                Section {
                    Button {
                        self.descritorSetter = .mostViewed
                    } label: {
                        HStack {
                            Text("Most viewed")
                                .robotoMono(.semibold, 15)
                            Spacer()
                            if self.descritorSetter == .mostViewed { Image(systemName: "checkmark").foregroundColor(Color("BackgroundColor2")) }
                            
                        }
                    }
                    Button {
                        self.descritorSetter = .leastViewed
                    } label: {
                        HStack {
                            Text("Least viewed")
                                .robotoMono(.semibold, 15)
                            Spacer()
                            if self.descritorSetter == .leastViewed { Image(systemName: "checkmark").foregroundColor(Color("BackgroundColor2")) }
                            
                        }
                    }

                }
                
                Section {
                    Button {
                        self.descritorSetter = .mostCommented
                    } label: {
                        HStack {
                            Text("Most commented")
                                .robotoMono(.semibold, 15)
                            Spacer()
                            if self.descritorSetter == .mostCommented { Image(systemName: "checkmark").foregroundColor(Color("BackgroundColor2")) }
                            
                        }
                    }
                    Button {
                        self.descritorSetter = .leastCommented
                    } label: {
                        HStack {
                            Text("Least commented")
                                .robotoMono(.semibold, 15)
                            Spacer()
                            if self.descritorSetter == .leastCommented { Image(systemName: "checkmark").foregroundColor(Color("BackgroundColor2")) }
                            
                        }
                    }

                }
            }
            .onAppear {
                self.descritorSetter = self.descriptor
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sort by")
                        .robotoMono(.bold, 17)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.descriptor = self.descritorSetter
                        self.dismiss.callAsFunction()
                    } label: {
                        Text("Done")
                            .robotoMono(.bold, 17, color: Color("BackgroundColor2"))
                    }

                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        self.dismiss.callAsFunction()
                    }.foregroundColor(Color("Register2"))

                }
            }
        }
    }
}

struct SortDescriptorsPickerSheetView_Previews: PreviewProvider {
    static var previews: some View {
        SortDescriptorsPickerSheetView(descriptor: .constant(.newest))
    }
}
