//
//  CombineTimer.swift
//  Coda
//
//  Created by Matoi on 09.04.2023.
//

import SwiftUI

import Combine
import Foundation

class CombineTimer: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    var timerSubscription: AnyCancellable?
    var completion: (() -> Void)?
    
    var secondsToSet: Int
    var secondsLeft: Int {
        didSet {
            objectWillChange.send()
            if secondsLeft < 0 {
                secondsLeft = secondsToSet
            }
            if secondsLeft == 0 {
                if let completion = self.completion {
                    completion()
                }
                timerSubscription?.cancel()
            }
        }
    }

    init(_ seconds: Int = 60) {
        self.secondsToSet = seconds
        self.secondsLeft = seconds
    }
    
    var isActive: Bool {
        self.secondsLeft > 0
    }

    func startTimer(completion: @escaping () -> Void) {
        self.completion = completion
        timerSubscription = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else {return}
                self.secondsLeft -= 1
                if self.secondsLeft == 0 {
                    completion()
                }
            })
    }

    func resetTimer(AndSetNewSeconds seconds: Int? = nil) {
        if let timerSubscription = timerSubscription {
            timerSubscription.cancel()
            if seconds != nil { self.secondsToSet = seconds! }
            self.secondsLeft = self.secondsToSet
            self.startTimer(completion: self.completion!)
        }
    }
}

