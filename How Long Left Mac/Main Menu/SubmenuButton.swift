//
//  SubmenuButton.swift
//  How Long Left Mac
//
//  Created by Ryan on 23/5/2024.
//

import FluidMenuBarExtra
import SwiftUI

struct SubmenuButton<Content: View>: View {
    @ObservedObject var model: WindowSelectionManager
    @EnvironmentObject var windowManager: FMBEWindowProxy

    @State private var isFlashing = false
    @State private var flashUUID: UUID?
    @State private var globalPosition: CGPoint = .zero
    @State private var lastUpdateTime = Date()
    @State private var debounceTimer: Timer?

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    let content: Content
    let action: () -> Void
    let opacity: Double
    let cornerRadius: CGFloat
    let padding: CGFloat
    let horizontalPadding: CGFloat

    let deselectDelay: Double
    let reselectDelay: Double
    let submenuContent: (() -> AnyView)?
    let idForHover: String
    let customHighlight: Color?
    let fill: Bool
    let showChevron: Bool

    let debounceInterval: TimeInterval = 0.1

    init(
        model: WindowSelectionManager,
        idForHover: String,
        opacity: Double = 0.2,
        cornerRadius: CGFloat = 5,
        padding: CGFloat = 6,
        horizontalPadding: CGFloat = 10,
        deselectDelay: Double = 0.1,
        reselectDelay: Double = 0.1,
        customHighlight: Color? = nil,
        fill: Bool = false,
        showChevron: Bool = true,
        submenuContent: (() -> AnyView)? = nil,
        @ViewBuilder content: () -> Content,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.opacity = opacity
        self.cornerRadius = cornerRadius
        self.submenuContent = submenuContent
        self.padding = padding
        self.horizontalPadding = horizontalPadding
        self.deselectDelay = deselectDelay
        self.reselectDelay = reselectDelay
        self.idForHover = idForHover
        self.content = content()
        self.action = action
        self.customHighlight = customHighlight
        self.fill = fill
        self.showChevron = showChevron
    }

    var body: some View {
        HStack {
            content
            if submenuContent != nil, showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .opacity(0.3)
            }
        }
        .padding(.vertical, padding)
        .padding(.horizontal, horizontalPadding)
        .background(backgroundView)
        .cornerRadius(cornerRadius)
        .onTapGesture(perform: handleTap)
        .onAppear(perform: setupSubwindow)
        .onHover { isHovering in
            model.setMenuItemHovering(id: isHovering ? idForHover : nil, hovering: isHovering)
        }
        .onChange(of: model.clickID) { _, newValue in
            if newValue == idForHover {
                handleTap()
                model.clickID = nil
            }
        }
        .background(geometryObserver)
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundStyle(backgroundColor)
            .opacity(backgroundOpacity)
    }

    private var backgroundColor: Color {
        // Check if we have a custom highlight colour and fill is enabled
        if isHighlighted, fill, let highlightColor = customHighlight {
            // Lighten or darken the colour based on the current appearance mode
            return (colorScheme == .dark)
                ? highlightColor.lighter() // Dark mode - darken the highlight
                : highlightColor.darker() // Light mode - lighten the highlight
        }
        return customHighlight ?? .primary
    }

    private var backgroundOpacity: Double {
        isHighlighted ? opacity : (fill ? 0.2 : 0.0)
    }

    private var isHighlighted: Bool {
        idForHover == model.menuSelection && !isFlashing
    }

    private func setupSubwindow() {
        if let content = submenuContent?() {
            windowManager.window?.registerSubwindowView(view: content, for: idForHover)
        }
    }

    private func handleTap() {
        flashButton()
        action()
    }

    private func flashButton() {
        let currentUUID = UUID()
        flashUUID = currentUUID
        withAnimation(.easeIn(duration: 0.08)) {
            isFlashing = true
        }
        Task {
            
            do {
                try await Task.sleep(nanoseconds: 80_000_000)
               if flashUUID == currentUUID {
                   isFlashing = false
               }
            } catch {
                print("Error flashing button: \(error)")
            }
            
        }
    }

    private var geometryObserver: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear {
                    updateGlobalPosition(from: geo.frame(in: .global).origin)
                }
                .onChange(of: geo.frame(in: .global).origin) { _, newOrigin in
                    let newPosition = newOrigin
                    DispatchQueue.main.async {
                        debounceOrThrottlePositionUpdate(newOrigin: newPosition)
                    }
                }
                .onDisappear {
                    model.setMenuItemHovering(id: nil, hovering: false)
                }
        }
    }

    private func debounceOrThrottlePositionUpdate(newOrigin: CGPoint) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { _ in
            if newOrigin != globalPosition {
                updateGlobalPosition(from: newOrigin)
            }
        }
    }

    private func updateGlobalPosition(from position: CGPoint) {
        globalPosition = position
        windowManager.window?.registerSubwindowButtonPosition(point: globalPosition, for: idForHover)
    }
}

extension Color {
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        adjustBrightness(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 30.0) -> Color {
        adjustBrightness(by: -abs(percentage))
    }

    private func adjustBrightness(by percentage: CGFloat) -> Color {
        // Convert the Color to a CGColor to get RGB components
        guard let cgColor = self.cgColor else { return self }

        // Get the RGB components (in the RGBA color space)
        let components = cgColor.components ?? [0, 0, 0, 1]
        let red = components[0]
        let green = components[1]
        let blue = components[2]

        // Adjust the RGB values to lighten or darken the color
        let adjustment = percentage / 100.0
        let adjustedR = min(max(red + adjustment, 0), 1)
        let adjustedG = min(max(green + adjustment, 0), 1)
        let adjustedB = min(max(blue + adjustment, 0), 1)

        // Return the new color
        return Color(red: adjustedR, green: adjustedG, blue: adjustedB)
    }
}
