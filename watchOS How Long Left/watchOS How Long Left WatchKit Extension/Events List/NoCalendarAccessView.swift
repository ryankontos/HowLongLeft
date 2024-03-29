//
//  NoCalendarAccessView.swift
//  watchOS How Long Left WatchKit Extension
//
//  Created by Ryan Kontos on 31/1/2022.
//  Copyright © 2022 Ryan Kontos. All rights reserved.
//

import SwiftUI

struct NoCalendarAccessView: View {
    
    
    var body: some View {
        
 

     
            VStack(spacing: 15) {

                        Spacer()
                        
                        VStack(spacing: 7) {
                        
                            Image(systemName: "calendar.badge.exclamationmark")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .secondary)
                                .font(.system(size: 52, weight: .regular, design: .default))
                                
                            
                     
                    
                            Text("How Long Left does not have access to your calendar.")
                                    .multilineTextAlignment(.center)
                            
                        }
                                
                               
                                NavigationLink(destination: { Text("You can resolve this by navigating to Privacy > Calendars in the Settings app on your Apple Watch or iPhone.") }, label: {
                                    
                                    Text("How To Fix...")
                                    
                                })
                                .foregroundStyle(.blue)
                                .buttonStyle(.plain)
                            
                            
                            
                            Spacer()
                        
                            
                }
                .frame(maxWidth: .infinity)
                .navigationTitle("How Long Left")
                .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom)
          
        
            
            
      
    
    }
    
    func makeAttributedString() -> AttributedString {
        
        let linkText = "Open Settings..."
        
        var string = AttributedString("How Long Left does not have access to your calendar. \(linkText)")
       
            
            if let range = string.range(of: linkText) { /// here!
                string[range].foregroundColor = .blue
            }
            return string
        }
    
}

struct NoCalendarAccessView_Previews: PreviewProvider {
    static var previews: some View {
        NoCalendarAccessView()
            .previewAllWatches()
    }
}
