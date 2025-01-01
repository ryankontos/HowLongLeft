//
//  EventListContent.swift
//  How Long Left
//
//  Created by Ryan on 30/11/2024.
//

import SwiftUI

struct EventListContent: View {
    var body: some View {
        
        VStack {
            
        
            getHeader("On Now")
            
            VStack {
                
                
                HStack(spacing: 13) {
                    
                    Circle()
                        .frame(width: 7)
                        .foregroundColor(.blue)
                        
                    
                    VStack(alignment: .leading) {
                        
                        Text("Event 1")
                            .fontWeight(.semibold)
                        Text("12:00 - 1:00")
                        
                    }
                   
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 10)
                
                .background(Color(UIColor.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(height: 65)
                
            }
            .padding(.top, 20)
                
                
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        
    }
    
    func getHeader(_ text: String) -> some View {
        HStack {
            Text(text)
                .fontWeight(.bold)
                .font(.title2)
            Spacer()
                
        }
    }

}

#Preview {
    EventListContent()
}
