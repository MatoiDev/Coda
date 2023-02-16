//
//  FreelanceSubTopicPicker.swift
//  Coda
//
//  Created by Matoi on 11.02.2023.
//


import SwiftUI

extension Font {
    static func avenirNext(size: Int) -> Font {
        return Font.custom("Avenir Next", size: CGFloat(size))
    }
    
    static func avenirNextRegular(size: Int) -> Font {
        return Font.custom("AvenirNext-Regular", size: CGFloat(size))
    }
}

struct FreelanceSubTopicButton<Content: View>: View {
    let action: () -> ()
    @ViewBuilder var label: () -> Content
    
    
    var body: some View {
        Button {
            self.action()
        } label: {
            self.label()
                .frame(width: UIScreen.main.bounds.width - 45, height: 45)
                .background(Color("AdditionBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .foregroundColor(.primary)
                .padding(.horizontal)
        }.SubTopicButtonStyle()
        
        
    }
}

fileprivate struct FreelanceSubTopicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .opacity(configuration.isPressed ? 0.75 : 1)
        
    }
}

extension View {
    fileprivate func SubTopicButtonStyle() -> some View {
        buttonStyle(FreelanceSubTopicButtonStyle())
    }
}

struct FreelanceSubTopicPicker: View {
    
    
    let topic: FreelanceTopic
    
    @Binding var topicToSet: FreelanceTopic
    @Binding var devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic
    @Binding var adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic
    @Binding var designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic
    @Binding var testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic
    
    @Binding var killPicker: Bool
    
    init(_ topic: FreelanceTopic,
         setTo topicToSet: Binding<FreelanceTopic>,
         devSubtopic: Binding<FreelanceSubTopic.FreelanceDevelopingSubTopic>,
         adminSubtopic: Binding<FreelanceSubTopic.FreelanceAdministrationSubTropic>,
         designSubtopic: Binding<FreelanceSubTopic.FreelanceDesignSubTopic>,
         testSubtopic: Binding<FreelanceSubTopic.FreelanceTestingSubTopic>,
         killOn killPicker: Binding<Bool>) {
        
        self.topic = topic
        self._topicToSet = topicToSet
        self._devSubtopic = devSubtopic
        self._adminSubtopic = adminSubtopic
        self._designSubtopic = designSubtopic
        self._testSubtopic = testSubtopic
        self._killPicker = killPicker
    }
    
    private let imageHeight: CGFloat = 175
    private let collapsedImageHeight: CGFloat = 75
    
    @ObservedObject private var articleContent: ViewFrame = ViewFrame()
    @State private var titleRect: CGRect = .zero
    @State private var headerImageRect: CGRect = .zero
    
    @Environment(\.dismiss) private var dissmiss
    
    func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let sizeOffScreen = imageHeight - collapsedImageHeight
        
        
        if offset < -sizeOffScreen {
            
            let imageOffset = abs(min(-sizeOffScreen, offset))
            
            return imageOffset - sizeOffScreen
        }
        
        if offset > 0 {
            
            return -offset
            
        }
        
        return 0
    }
    
    func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        
        if offset > 0 {
            return imageHeight + offset
        }
        
        return imageHeight
    }
    
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height
        
        return blur * 6
    }
    
    
    
    private func getHeaderTitleOffset() -> CGFloat {
        let currentYPos = titleRect.midY
        if currentYPos < headerImageRect.maxY {
            let minYValue: CGFloat = 50.0
            let maxYValue: CGFloat = collapsedImageHeight
            let currentYValue = currentYPos
            
            let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue))
            let finalOffset: CGFloat = -30.0
            print(20 - (percentage * finalOffset))
            return (20 - (percentage * finalOffset)) < 120 ? 120 : (20 - (percentage * finalOffset))
        }
        
        return .infinity
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizedStringKey(self.topic.rawValue))
                            .font(.avenirNext(size: 28))
                            .background(GeometryGetter(rect: self.$titleRect))
                        switch self.topic {
                        case .Administration:
                            ForEach(FreelanceSubTopic.FreelanceAdministrationSubTropic.values, id: \.self) { subTopic in
                                FreelanceSubTopicButton {
                                    self.topicToSet = .Administration
                                    self.adminSubtopic = subTopic
                                    self.killPicker.toggle()
                                } label: {
                                    Text(LocalizedStringKey(subTopic.rawValue))
                                }
                            }
                            
                        case .Development:
                            ForEach(FreelanceSubTopic.FreelanceDevelopingSubTopic.values, id: \.self) { subTopic in
                                FreelanceSubTopicButton {
                                    self.topicToSet = .Development
                                    self.devSubtopic = subTopic
                                    self.killPicker.toggle()
                                } label: {
                                    Text(LocalizedStringKey(subTopic.rawValue))
                                }
                            }
                            
                        case .Design:
                            ForEach(FreelanceSubTopic.FreelanceDesignSubTopic.values, id: \.self) { subTopic in
                                FreelanceSubTopicButton {
                                    self.topicToSet = .Design
                                    self.designSubtopic = subTopic
                                    self.killPicker.toggle()
                                } label: {
                                    Text(LocalizedStringKey(subTopic.rawValue))
                                }
                            }
                            
                        case .Testing:
                            ForEach(FreelanceSubTopic.FreelanceTestingSubTopic.values, id: \.self) { subTopic in
                                FreelanceSubTopicButton {
                                    self.topicToSet = .Testing
                                    self.testSubtopic = subTopic
                                    self.killPicker.toggle()
                                } label: {
                                    Text(LocalizedStringKey(subTopic.rawValue))
                                }
                            }
                            
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16.0)
                    Text("").frame(height: 65)
                    
                }
                .offset(y: imageHeight + 16)
                .background(GeometryGetter(rect: $articleContent.frame))
                
                GeometryReader { geometry in
                    
                    ZStack(alignment: .bottom) {
                        Image("Freelance\(self.topic.rawValue)")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry) / 3)
                            .blur(radius: self.getBlurRadiusForImage(geometry))
                            .clipped()
                            .background(GeometryGetter(rect: self.$headerImageRect))
                        HStack {
                            if self.topic == .Testing {
                                Spacer()
                            }
                            Text(LocalizedStringKey(self.topic.rawValue))
                                .padding(self.topic != .Testing ? .leading : .trailing)
                                .padding(self.topic != .Testing ? .leading : .trailing)
                            
                            if self.topic != .Testing {
                                Spacer()
                            }
                            
                        }
                        
                        .font(.avenirNext(size: 17).bold())
                        .foregroundColor(.white)
                        .offset(x: 0, y: self.getHeaderTitleOffset() - 125)
                    }
                    .clipped()
                    .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                }.frame(height: imageHeight)
                    .offset(x: 0, y: -(articleContent.startingRect?.maxY ?? UIScreen.main.bounds.height))
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            
            Button {
                self.dissmiss.callAsFunction()
            } label: {
            Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.primary)
                    .frame(width: 35, height: 35)
                    .padding(.leading, 24)
            }
        }
    }
}

class ViewFrame: ObservableObject {
    var startingRect: CGRect?
    
    @Published var frame: CGRect {
        willSet {
            if startingRect == nil {
                startingRect = newValue
            }
        }
    }
    
    init() {
        self.frame = .zero
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            AnyView(Color.clear)
                .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))
        }.onPreferenceChange(RectanglePreferenceKey.self) { (value) in
            self.rect = value
        }
    }
}

struct RectanglePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}



