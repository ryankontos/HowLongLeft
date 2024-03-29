//
//  CountdownCellView.swift
//  How Long Left iOS App
//
//  Created by Ryan Kontos on 27/7/2022.
//  Copyright © 2022 Ryan Kontos. All rights reserved.
//

import UIKit
import Combine

class CountdownCellView: RepesentedEventView {

    var titleLabel: MarqueeLabel?
    var statusLabel: UILabel?
    
    var timerLabel: UILabel?
    
    var ac: AnyCancellable?
    
    let background = UIView()
    let progressOverlay = UIView()
    var widthContraint: NSLayoutConstraint?
    
    
    static let shadowOpacity: Float = 0.3
    static let shadowRadius: CGFloat = 5
    
    static let labelAlpha: CGFloat = 0.9
    
    override func configureForEvent(event: HLLEvent) {
        
        // print("Configuring current cell for event")
        
        self.updateCountdownLabel()
        
        super.configureForEvent(event: event)
        
        self.event = event
        
        updateGradient()
        
        updateCountdownLabel()
        
      
    }
    
    func updateGradient() {
        
        background.backgroundColor = event!.color.darker(by: 10)?.withAlphaComponent(0.7)
        progressOverlay.backgroundColor = event!.color.darker(by: 10)?.withAlphaComponent(0.7)
      


        
    }
    
    override func configure() {
        
        super.configure()
        // print("Configuring current cell")
      
        
     
        //background.alpha = 0.5
        self.addSubview(background)
        
        background.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            background.heightAnchor.constraint(equalTo: heightAnchor),
            background.widthAnchor.constraint(equalTo: widthAnchor),
            background.centerXAnchor.constraint(equalTo: centerXAnchor),
            background.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            
        ])
        
        background.addSubview(progressOverlay)
        
        progressOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressOverlay.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            progressOverlay.topAnchor.constraint(equalTo: background.topAnchor),
            progressOverlay.bottomAnchor.constraint(equalTo: background.bottomAnchor),
        ])
        
       // self.widthContraint = progressOverlay.widthAnchor.constraint(equalTo: background.widthAnchor, multiplier: 0.5)
       // self.widthContraint?.isActive = true
        
        self.alpha = 1
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        titleLabel = MarqueeLabel()
        let titleLabel = titleLabel!
        titleLabel.fadeLength = 10
        
 
        statusLabel = UILabel()
        let statusLabel = statusLabel!
        
        timerLabel = UILabel()
        let timerLabel = timerLabel!
        
        layer.cornerCurve = .continuous
        layer.cornerRadius = 25
        layer.masksToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        
        titleLabel.alpha = CountdownCellView.labelAlpha
        titleLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        titleLabel.layer.shadowOpacity = CountdownCellView.shadowOpacity
        titleLabel.layer.shadowRadius = CountdownCellView.shadowRadius
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shouldRasterize = true
        
       // addSubview(titleLabel)
        
        statusLabel.alpha = CountdownCellView.labelAlpha
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textColor = .white
        statusLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        
        statusLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        statusLabel.layer.shadowOpacity = CountdownCellView.shadowOpacity
        statusLabel.layer.shadowRadius = CountdownCellView.shadowRadius
        statusLabel.layer.shadowColor = UIColor.black.cgColor
        statusLabel.layer.shouldRasterize = true
        
        
       // addSubview(statusLabel)
        
        timerLabel.alpha = CountdownCellView.labelAlpha
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.textColor = .white
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .medium)
        
        timerLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        timerLabel.layer.shadowOpacity = CountdownCellView.shadowOpacity
        timerLabel.layer.shadowRadius = CountdownCellView.shadowRadius
        timerLabel.layer.shadowColor = UIColor.black.cgColor
        timerLabel.layer.shouldRasterize = true
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        stack.axis = .vertical
        
        stack.spacing = 6
        background.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        background.addSubview(timerLabel)
        let inset = CGFloat(20)
        let verticalInset = CGFloat(12)
        NSLayoutConstraint.activate([
            stack.heightAnchor.constraint(equalToConstant: 56),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: timerLabel.leadingAnchor, constant: -10),
        ])
        
        let timerTrailing = timerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        timerTrailing.isActive = true
        timerTrailing.priority = .defaultHigh
        
        timerLabel.setContentHuggingPriority(.required, for: .horizontal)
        timerLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        stack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        updateGradient()
        
    }

    func updateCountdownLabel() {
        
        if let updated = event?.getUpdatedInstance() {
            self.event = updated
        }

        
        if let event = event {
            
            titleLabel?.text = event.title
            
            statusLabel?.text = "\(event.countdownTypeString())"
            self.timerLabel?.text = CountdownStringGenerator.generatePositionalCountdown(event: event, at: Date())
            
            if event.completionStatus == .current {
                progressOverlay.isHidden = false
                
                let completion = event.completionFraction
                
                self.widthContraint?.isActive = false
                
               
                    self.widthContraint = self.progressOverlay.widthAnchor.constraint(equalTo: self.background.widthAnchor, multiplier: completion)
                    
                    
                    self.widthContraint?.isActive = true
                    
                
                
                
            } else {
                progressOverlay.isHidden = true
            }
            
        } else {
            ac?.cancel()
        }
        
    }
    
    func setLabelAlpha(_ value: CGFloat) {
        
        titleLabel?.alpha = value
        statusLabel?.alpha = value
        timerLabel?.alpha = value
        
    }
    
    func removeLabels() {
        
        return;
        
        titleLabel?.removeFromSuperview()
        titleLabel = nil
        
        statusLabel?.removeFromSuperview()
        statusLabel = nil
        
        timerLabel?.removeFromSuperview()
        timerLabel = nil
        
        self.alpha = 0.2
    }
    
  
    
}


class LayerContainerView: UIView {

    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
}
