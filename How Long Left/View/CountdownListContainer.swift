//
//  CountdownListContainer.swift
//  How Long Left
//
//  Created by Ryan on 31/5/2025.
//

import SwiftUI
import HowLongLeftKit

struct CountdownListContainer: View {
    
    @EnvironmentObject var pointStore: TimePointStore
    
    var body: some View {
        CountdownList()
    }
}

#Preview {
    CountdownListContainer()
}
