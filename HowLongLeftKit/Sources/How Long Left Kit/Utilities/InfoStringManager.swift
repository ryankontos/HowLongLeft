//
//  InfoStringManager.swift
//
//
//  Created by Ryan on 18/6/2024.
//

import Foundation
import Combine

@MainActor
public class InfoStringManager: ObservableObject {
    @Published public var infoString: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    private var stringGenerator: EventInfoStringGenerator
    private var event: HLLEvent
    
    public init(event: HLLEvent, stringGenerator: EventInfoStringGenerator) {
        
        self.event = event
        self.stringGenerator = stringGenerator
        
        updateInfo()
        
       
    }
    
    public func setPublisher(_ publisher: AnyPublisher<Void, Never>) {
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateInfo()
            }
            .store(in: &cancellables)
    }
    
    private func updateInfo() {
        let newString = self.stringGenerator.getString(from: self.event, at: Date())
        self.infoString = newString
    }
}


