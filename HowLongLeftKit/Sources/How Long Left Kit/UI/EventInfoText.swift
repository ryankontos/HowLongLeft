//
//  SwiftUIView.swift
//  
//
//  Created by Ryan on 19/6/2024.
//

import SwiftUI

public struct EventInfoText: View {
    
    @ObservedObject private var timerContainer = GlobalTimerContainer.shared
    
    @ObservedObject private var infoStringGen: InfoStringManager
    
    private var event: HLLEvent
    
    public init(_ event: HLLEvent, stringGenerator: EventInfoStringGenerator) {
        self.event = event
        self.infoStringGen = InfoStringManager(event: event, stringGenerator: stringGenerator)
    }
    
    public var body: some View {
        Text(infoStringGen.infoString)
            .monospacedDigit()
            .onAppear() {
                infoStringGen.setPublisher(timerContainer.everySecondPublisher)
            }
            .transaction {
                $0.animation = nil
            }
    }
}
