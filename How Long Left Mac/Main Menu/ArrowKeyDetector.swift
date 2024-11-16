//
//  ArrowKeyDetector.swift
//  How Long Left Mac
//
//  Created by Ryan on 25/5/2024.
//

import Foundation
import SwiftUI

struct ArrowKeyDetector: NSViewRepresentable {
    var id: String

    var onLeftArrow: (() -> Void)?
    var onRightArrow: (() -> Void)?
    var onUpArrow: (() -> Void)?
    var onDownArrow: (() -> Void)?
    var onEnter: (() -> Void)?
    var onEsc: (() -> Void)?

    class Coordinator: NSObject {
        var parent: ArrowKeyDetector

        init(_ parent: ArrowKeyDetector) {
            self.parent = parent
        }

        @objc func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case 123: // Left arrow key code
                parent.onLeftArrow?()
            case 124: // Right arrow key code
                parent.onRightArrow?()
            case 125: // Down arrow key code
                parent.onDownArrow?()
            case 126: // Up arrow key code
                parent.onUpArrow?()
            case 36: // Up arrow key code
                parent.onEnter?()
            case 53: // Up arrow key code
                parent.onEsc?()

            default:
                break
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSView {
        let view = CustomKeyView()
        view.coordinator = context.coordinator
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}

    class CustomKeyView: NSView {
        var coordinator: Coordinator?

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.wantsLayer = true
            self.layer?.backgroundColor = NSColor.clear.cgColor
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override func keyDown(with event: NSEvent) {
            coordinator?.keyDown(with: event)
        }

        override var acceptsFirstResponder: Bool {
            true
        }

        override func viewDidMoveToWindow() {
            // print("Make FR \(coordinator!.parent.id)")
            // window!.makeFirstResponder(self)

        }
    }
}
