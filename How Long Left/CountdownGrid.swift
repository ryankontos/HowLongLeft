//
//  CountdownGrid.swift
//  How Long Left
//
//  Created by Ryan on 30/12/2024.
//

import SwiftUI
import HowLongLeftKit

struct GridEventItem: Identifiable {
    let id = UUID()
    let name: String
    let daysLeft: Int
    let isAllDay: Bool
    let progress: Double // 0.0 to 1.0
    let themeColor: Color
}

struct CountdownGrid: View {
    // Sample event data
    @State private var events: [GridEventItem] = [
        GridEventItem(name: "Christmas 🎄", daysLeft: 72, isAllDay: false, progress: 0.2, themeColor: .red),
        GridEventItem(name: "Ski season ⛷️", daysLeft: 36, isAllDay: false, progress: 0.4, themeColor: .blue),
        GridEventItem(name: "Health check", daysLeft: 4, isAllDay: false, progress: 0.9, themeColor: .gray),
        GridEventItem(name: "Ana's birthday 🎉", daysLeft: 3, isAllDay: true, progress: 0.1, themeColor: .green),
        GridEventItem(name: "Movie night", daysLeft: 5, isAllDay: false, progress: 0.8, themeColor: .pink),
        GridEventItem(name: "Hawaii trip", daysLeft: 12, isAllDay: false, progress: 0.6, themeColor: .cyan),
        GridEventItem(name: "Retirement 🧓", daysLeft: 365, isAllDay: false, progress: 0.3, themeColor: .orange)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 300, maximum: 600), spacing: 20)
                        ],
                        spacing: 16 // Vertical spacing
                    ) {
                        ForEach(events.filter { !$0.isAllDay }.sorted { $0.daysLeft < $1.daysLeft }) { event in
                            EventView(event: event)
                        }
                    }
                    .padding([.leading, .trailing])
                    .padding(.top, 20)
                }
            }
            
            .navigationTitle("How Long Left")
        }
       
    }
}

struct EventView: View {
    let event: GridEventItem
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 25, style: .circular)
                .fill(event.themeColor.gradient.opacity(0.7))
            
            VStack(alignment: .leading) {
                
                
                HStack(spacing: 6) {
                    
                    Image(systemName: "calendar")
                    Text("Home")
                        .font(.headline)
                    
                    Spacer()
                }
                
                RoundedRectangle(cornerRadius: 25, style: .circular)
                    .frame(height: 1.5)
                    .opacity(0.3)
                
                Spacer()
                
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .shadow(radius: 3)
            
        }
        .frame(height: 170)
    }
}

struct CountdownGrid_Previews: PreviewProvider {
    static var previews: some View {
        CountdownGrid()
    }
}
