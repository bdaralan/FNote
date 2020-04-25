//
//  OnboardView.swift
//  FNote
//
//  Created by Dara Beng on 2/13/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct OnboardView: View {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @ObservedObject var viewModel: OnboardCollectionViewModel
    
    var includeXButton = false
    
    var alwaysShowXButton = false
    
    var onDismiss: () -> Void
        
    var isPhoneLandscape: Bool {
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        return isPhone && verticalSizeClass == .compact
    }
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    
    var body: some View {
        OnboardViewControllerWrapper(viewModel: viewModel)
            .overlay(pageControl, alignment: isPhoneLandscape ? .bottomTrailing : .bottom)
            .overlay(dismissXButton, alignment: .topTrailing)
            .overlay(dragHandle.padding(.top, 8), alignment: .top)
            .background(gradientBackground.edgesIgnoringSafeArea(.all))
    }
}


extension OnboardView {
    
    func setupPageControl(_ control: UIPageControl) {
        control.isUserInteractionEnabled = false
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
}


extension OnboardView {
    
    var pageControl: some View {
        VStack(alignment: isPhoneLandscape ? .trailing : .center, spacing: 16) {
            if viewModel.hasLastPageShown {
                Button(action: onDismiss) {
                    Text("Get Started")
                        .font(Font.system(isPhoneLandscape ? .body : .title, design: .rounded).bold())
                        .padding(.vertical)
                        .padding(.horizontal, 32)
                        .background(Color.white.opacity(0.7))
                        .foregroundColor(.black)
                        .cornerRadius(100)
                }
                .transition(AnyTransition.scale.animation(.spring()))
            }
            
            PageControlWrapper(
                currentPage: $viewModel.currentPage,
                pageCount: viewModel.pages.count,
                configure: setupPageControl
            )
                .padding(.horizontal, 24)
                .background(Color.white.opacity(0.7))
                .cornerRadius(100)
                .padding(.bottom, isPad ? 16 : 8)
        }
        .padding(.trailing, isPhoneLandscape ? 8 : 0)
    }
    
    var dismissXButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .frame(width: 50, height: 50)
        }
        .accentColor(.black)
        .opacity(viewModel.hasLastPageShown && includeXButton || alwaysShowXButton ? 1 : 0)
    }
    
    var dragHandle: some View {
        BDModalDragHandle(color: .black, hideOnVerticalCompact: true)
    }
    
    var gradientBackground: some View {
        let top = Color(UIColor(hex: "FF9414"))
        let bottom = Color(UIColor(hex: "FF1452"))
        let gradient = Gradient(colors: [top, bottom])
        return LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
            .background(bottom)
    }
}


struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(viewModel: .init(), onDismiss: {})
    }
}
