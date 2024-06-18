//
//  EventInfoItemView.swift
//  How Long Left Mac
//
//  Created by Ryan on 18/6/2024.
//

import SwiftUI

struct EventInfoItemView<Content: View>: View {
    
    var symbol: String
    var color: Color
    var infoView: () -> Content
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            
            Image(systemName: symbol)
                .foregroundStyle(color)
                .frame(width: 12)
            
            VStack {
                
                infoView()
                //.padding(.top, 1)
                
            }
        }
    }
}



