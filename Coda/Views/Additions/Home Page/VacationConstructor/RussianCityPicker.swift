//
//  RussianCityPicker.swift
//  Coda
//
//  Created by Matoi on 25.02.2023.
//

import SwiftUI

struct RussianCityPicker: View {
    @Binding var city: String
    
    @State private var queryString: String = ""
    
    @State private var allCities: Array<City> = []
    
    @State private var filteredCities: Array<City> = []
    
    @Environment(\.dismiss) var dismiss
    
    init(city: Binding<String>) {
        self._city = city
       
    }
    var body: some View {
        List {
            
            ForEach(0..<(self.filteredCities.count > 250 ? 250 : self.filteredCities.count), id: \.self) { cityInd in
                let name = self.filteredCities[cityInd].name
                let subject = self.filteredCities[cityInd].subject
                let district = self.filteredCities[cityInd].district
                
                Button {
                    self.city = "\(name), \(subject), \(district)"
                    self.dismiss.callAsFunction()
                } label: {
                    Text("\(name), \(subject), \(district)")
                        .robotoMono(.semibold, 15)
                }
            }
            Text("")
                .frame(height: 50)
                
            
        }.listStyle(.plain)
        .onAppear {
            if let citiesData = RussianCitiesJSONParser.readLocalJSONFile(forName: "RussianCities"),
               let cities = RussianCitiesJSONParser.parse(jsonData: citiesData)
            {
                
                self.allCities = cities
                self.filteredCities = cities
            }
        }
        .task {
            if let citiesData = RussianCitiesJSONParser.readLocalJSONFile(forName: "RussianCities"),
               let cities = RussianCitiesJSONParser.parse(jsonData: citiesData)
            {
                print("Нашёл города: \(cities[0].name)")
                self.allCities = cities
                self.filteredCities = cities
            }
        }
        .navigationTitle("Choose city")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: self.$queryString, placement: .navigationBarDrawer(displayMode: .always), prompt: Text(LocalizedStringKey("City search"))) {
            Text("Москва").searchCompletion("Москва, Москва, Центральный")
                .robotoMono(.medium, 15, color: .blue)
            Text("Санкт-Петербург").searchCompletion("Санкт-Петербург, Санкт-Петербург, Северо-Западный")
                .robotoMono(.medium, 15, color: .blue)
            Text("Новосибирск").searchCompletion("Новосибирск, Новосибирская область, Сибирский")
                .robotoMono(.medium, 15, color: .blue)
            Text("Екатеринбург").searchCompletion("Екатеринбург, Свердловская область, Уральский")
                .robotoMono(.medium, 15, color: .blue)
            Text("Казань").searchCompletion("Казань, Татарстан, Приволжский")
                .robotoMono(.medium, 15, color: .blue)
            
        }
        .onChange(of: self.queryString) { text in
            if text.isEmpty {
                self.filteredCities = self.allCities
            } else {
                self.filteredCities = self.filteredCities.filter{ "\($0.name), \($0.subject), \($0.district)".contains(text) }
            }
        }
        
       
    }
}

//struct RussianCityPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        RussianCityPicker()
//    }
//}
