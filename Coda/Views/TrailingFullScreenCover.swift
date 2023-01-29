//
//  TrailingFullScreenCover.swift
//  Coda
//
//  Created by Matoi on 28.01.2023.
//

import SwiftUI

struct TrailingFullScreenCover<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            content
                .environment(\.easyDismiss, EasyDismiss {
                    isPresented = false
                })
        }
    }
}

extension View {
    func trailingFullScreenCover<Content>(isPresented: Binding<Bool>, transition: AnyTransition = .move(edge: .trailing), content: @escaping () -> Content) -> some View where Content : View {
        ZStack {
            self
            ZStack {
                if isPresented.wrappedValue {
                    TrailingFullScreenCover(isPresented: isPresented, content: content)
                        .transition(transition)
                }
            }
        }
    }
}

struct EasyDismiss {
    private var action: () -> Void
    func callAsFunction() {
        action()
    }
    
    init(action: @escaping () -> Void = { }) {
        self.action = action
    }
}

struct EasyDismissKey: EnvironmentKey {
    static var defaultValue: EasyDismiss = EasyDismiss()
}

extension EnvironmentValues {
    var easyDismiss: EasyDismiss {
        get { self[EasyDismissKey.self] }
        set { self[EasyDismissKey.self] = newValue }
    }
}


