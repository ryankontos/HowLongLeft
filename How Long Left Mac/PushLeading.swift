//
//  PushLeading.swift
//  How Long Left Mac
//
//  Created by Ryan on 14/5/2024.
//

import SwiftUI

struct PushLeading<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            content
            Spacer()
        }
    }
}
