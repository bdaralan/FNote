//
//  DividerLine.swift
//  FNote
//
//  Created by Dara Beng on 2/27/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class DividerLine: UIView {
    
    let line = UIView()
    let leadingCircle = UIView()
    let trailingCircle = UIView()
    
    private let circleRadius: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leadingCircle.layer.cornerRadius = circleRadius / 2
        trailingCircle.layer.cornerRadius = circleRadius / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(_ color: UIColor) {
        line.backgroundColor = color
        leadingCircle.backgroundColor = color
        trailingCircle.backgroundColor = color
    }
    
    private func setupView() {
        setColor(.black)
    }
    
    private func setupConstraints() {
        addSubviews(line, leadingCircle, trailingCircle, useAutoLayout: true)
        NSLayoutConstraint.activateConstraints(
            line.centerXAnchor.constraint(equalTo: centerXAnchor),
            line.centerYAnchor.constraint(equalTo: centerYAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.widthAnchor.constraint(equalTo: widthAnchor),
            
            leadingCircle.widthAnchor.constraint(equalToConstant: circleRadius),
            leadingCircle.heightAnchor.constraint(equalToConstant: circleRadius),
            leadingCircle.centerXAnchor.constraint(equalTo: line.leadingAnchor),
            leadingCircle.centerYAnchor.constraint(equalTo: line.centerYAnchor),
            
            trailingCircle.widthAnchor.constraint(equalToConstant: circleRadius),
            trailingCircle.heightAnchor.constraint(equalToConstant: circleRadius),
            trailingCircle.centerXAnchor.constraint(equalTo: line.trailingAnchor),
            trailingCircle.centerYAnchor.constraint(equalTo: line.centerYAnchor)
        )
    }
}


// MARK: - Wrapper

import SwiftUI


struct DividerLineWrapper: UIViewRepresentable {
    
    // MARK: Property
    
    var color: UIColor
    
    
    // MARK: Make View
    
    func makeUIView(context: Context) -> DividerLine {
        DividerLine()
    }
    
    func updateUIView(_ uiView: DividerLine, context: Context) {
        uiView.setColor(color)
    }
}
