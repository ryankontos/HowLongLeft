//
//  MenuButton.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/5/2024.
//

import Foundation
import SwiftUI
import FluidMenuBarExtra

struct MenuButton<Content: View>: View, SubwindowDelegate {

    @ObservedObject var model: MainMenuViewModel
    @EnvironmentObject var windowManager: FluidMenuBarExtraWindowManager
    
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
        model: MainMenuViewModel,
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
            Spacer()
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
            visible = true
        }
        .onDisappear {
            visible = false
        }
        .onHover { hovering in
           
            model.selectIDFromHover(hovering ? idForHover : nil)
        }
        .onChange(of: model.clickID) { (old, newValue) in
            if newValue == idForHover {
                flashButton()
                action()
                DispatchQueue.main.async {
                    model.clickID = nil
                }
            }
        }
        .onChange(of: model.selectedItemID) { (old, newValue) in
            
           
                handleSelectionChange(oldValue: old, newValue: newValue)
            
            
           
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        globalPosition = geo.frame(in: .global).origin
                    }
                    .onChange(of: geo.frame(in: .global).origin) { (old, newOrigin) in
                        //print("Frame changed")
                        
                        globalPosition = newOrigin
                        
                        
                    }
            }
        }
    }
    
    private func getBackgroundColor() -> Color {
        
        return isHighlighted() ? .primary : customHighlight ?? .primary
        
    }
    
    private func getBackgroundOpactiy() -> Double {
        
        
        return isHighlighted() ? opacity : (fill ? 0.05 : 0.0)
        
    }
    
    func isHighlighted() -> Bool {
        
       return (idForHover == model.selectedItemID) && !isFlashing
        
    }
    
    private func handleSelectionChange(oldValue: String?, newValue: String?) {
        
        //print("HLD: Selection old: \(oldValue ?? "nil") \(newValue ?? "nil")")
        
        // If the new value is not equal to the idForHover, handle the deselection logic
        
        if oldValue != nil, newValue != idForHover {
            windowManager.closeSubwindow(force: false, notify: false)
            
        }
        
        if oldValue == idForHover && newValue == nil {
            windowManager.closeSubwindow(notify: false)
            return
        }
        
        guard newValue == idForHover else {
            //print("HSCC1 \(idForHover.prefix(10))")
            
            return
        }
        
        

        if oldValue != idForHover, model.lastSelectWasByKey {
            //print("HSCC2")
           
                // Scroll to the item with idForHover, anchoring at the bottom
                model.scrollProxy?.scrollTo(idForHover, anchor: .bottom)
            
        }
        
        
        DispatchQueue.main.async {
            
            // If there is submenu content, open the subwindow with the submenu content
            if let submenuContent = submenuContent {
                
                //print("HSCC3")
                // Set the current subwindow delegate to self
                windowManager.currentSubwindowDelegate = self
                inWindow = true
                // Open the subwindow at the global position with the provided submenu content
                windowManager.openSubWindow(id: idForHover, at: globalPosition, view: AnyView(submenuContent()))
            } else {
                windowManager.closeSubwindow()
            }
            
        }

        // If the old value was not equal to idForHover and the last selection was by key, scroll to the item
       
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
