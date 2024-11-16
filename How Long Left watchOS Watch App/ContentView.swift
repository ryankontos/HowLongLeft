//
//  ContentView.swift
//  How Long Left watchOS Watch App
//
//  Created by Ryan on 24/9/2024.
//

import HowLongLeftKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pointStore: TimePointStore

    var body: some View {
        if let point = pointStore.currentPoint {
            List {
                ForEach(point.allEvents) { event in
                    Text(event.title)
                }
            }
        } else {
            Text("No point!")
        }
    }
}

#Preview {
    ContentView()
}
