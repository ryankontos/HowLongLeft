//
//  PageControl.swift
//  How Long Left
//
//  Created by Ryan on 11/6/2025.
//

import Foundation
import UIKit
import SwiftUI


struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.currentPageIndicatorTintColor = .secondaryLabel
        control.pageIndicatorTintColor = .tertiaryLabel
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.pageChanged(_:)),
            for: .valueChanged
        )
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = currentPage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: PageControl
        init(_ parent: PageControl) { self.parent = parent }

        @objc func pageChanged(_ sender: UIPageControl) {
            parent.currentPage = sender.currentPage
        }
    }
}

