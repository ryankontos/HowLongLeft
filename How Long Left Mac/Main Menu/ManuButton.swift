//
//  MenuButton.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/5/2024.
//

import Foundation
import SwiftUI
import FluidMenuBarExtra

struct MenuButton<Content: View>: View {

    @ObservedObject var model: WindowSelectionManager
    @EnvironmentObject var windowManager: FMBEWindowProxy
    
    @State private var isHovering = false
    @State private var isFlashing = false
    @State private var flashUUID: UUID? = nil
    @State private var visible = false
    @State private var inWindow = false
    @State private var globalPosition: CGPoint = .zero
    @State private var hoverWorkItem: DispatchWorkItem?

    let content: Content
    let action: () -> Void
    let opacity: Double
    let cornerRadius: CGFloat
    let padding: CGFloat
    let deselectDelay: Double
    let reselectDelay: Double
    let submenuContent: (() -> AnyView)?
    let idForHover: String
    let customHighlight: Color?
    let fill: Bool

    init(
        model: WindowSelectionManager,
        idForHover: String,
        opacity: Double = 0.2,
        cornerRadius: CGFloat = 5,
        padding: CGFloat = 6,
        deselectDelay: Double = 0.1,
        reselectDelay: Double = 0.1,
        customHighlight: Color? = nil,
        fill: Bool = false,
        submenuContent: (() -> AnyView)? = nil,
        @ViewBuilder content: () -> Content,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.opacity = opacity
        self.cornerRadius = cornerRadius
        self.submenuContent = submenuContent
        self.padding = padding
        self.deselectDelay = deselectDelay
        self.reselectDelay = reselectDelay
        self.idForHover = idForHover
        self.content = content()
        self.action = action
        self.customHighlight = customHighlight
        self.fill = fill
    }

    var body: some View {
        HStack {
            content
            
            if submenuContent != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .opacity(0.3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, padding)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundStyle(getBackgroundColor())
                .opacity(getBackgroundOpactiy())
        )
        .onTapGesture {
            flashButton()
            action()
        }
        .cornerRadius(cornerRadius)
        .onAppear {
            
            if let content = submenuContent?() {
                windowManager.window?.registerSubwindowView(view: content, for: idForHover)
            }
            
           
        }
        
        .onHover { hovering in
           
            model.setMenuItemHovering(id: hovering ? idForHover : nil, hovering: hovering)
            
        }
        .onChange(of: model.clickID) { newValue in
            if newValue == idForHover {
                flashButton()
                action()
                DispatchQueue.main.async {
                    model.clickID = nil
                }
            }
        }
       
        .background {
            GeometryReader { geo in
                Color.clear
                    .onDisappear() {
                        model.setMenuItemHovering(id: nil, hovering: false)
                        
                    }
                    .onAppear {
                       
                        globalPosition = geo.frame(in: .global).origin
                        windowManager.window?.registerSubwindowButtonPosition(point: globalPosition, for: idForHover)
                    }
                    .onChange(of: geo.frame(in: .global).origin) { newOrigin in
                        //print("Frame changed")
                        
                        globalPosition = newOrigin
                        windowManager.window?.registerSubwindowButtonPosition(point: globalPosition, for: idForHover)
                        
                        
                        
                    }
            }
        }
    }
    
    private func getBackgroundColor() -> Color {
        
        return isHighlighted() ? .primary : customHighlight ?? .primary
        
    }
    
    private func getBackgroundOpactiy() -> Double {
        
        
        return isHighlighted() ? opacity : (fill ? 0.1 : 0.0)
        
    }
    
    func isHighlighted() -> Bool {
        
       return (idForHover == model.menuSelection) && !isFlashing
        
    }
    
  

    
    func mouseExitedSubwindow() {
        inWindow = false
    }
    
    private func flashButton() {
        let currentUUID = UUID()
        flashUUID = currentUUID
        isFlashing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            if flashUUID == currentUUID {
                isFlashing = false
            }
        }
    }
}
