//
//  OnboardView.swift
//  FNote
//
//  Created by Dara Beng on 2/13/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct OnboardView: View {
    
    var onDismiss: () -> Void
    
    @State private var viewModel = OnboardCollectionViewModel()
    @State private var currentPage = 0
    
    @State private var hasLastPageShown = false
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            CollectionViewWrapper(viewModel: _viewModel.wrappedValue)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                if hasLastPageShown {
                    Button(action: onDismiss) {
                        Text("Get Started")
                            .font(Font.system(.title, design: .rounded).bold())
                            .padding(.vertical)
                            .padding(.horizontal, 32)
                            .background(Color.white.opacity(0.7))
                            .foregroundColor(.black)
                            .cornerRadius(100)
                    }
                }
             
                PageControlWrapper(
                    currentPage: $currentPage,
                    pageCount: viewModel.pages.count,
                    configure: setupPageControl
                )
                    .padding(.horizontal, 24)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(100)
                    .padding(.bottom, 16)
            }
        }
        .overlay(dragHandle.padding(.top, 8), alignment: .top)
        .background(gradientBackground.edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.horizontal)
        .onAppear(perform: setupOnAppear)
    }
}


extension OnboardView {
    
    func setupOnAppear() {
        viewModel.onPageChanged = handlePageChanged
        viewModel.pages.forEach({ UIImage.preload(name: $0.imageName) })
    }
    
    func handlePageChanged(pageIndex: Int, page: OnboardPage) {
        currentPage = pageIndex
        if pageIndex == viewModel.pages.count - 1 {
            hasLastPageShown = true
        }
    }
    
    func setupPageControl(_ control: UIPageControl) {
        control.isUserInteractionEnabled = false
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
}


extension OnboardView {
    
    var dragHandle: some View {
        ModalDragHandle(color: .black, hideOnLandscape: true)
    }
    
    var gradientBackground: some View {
        let top = Color(UIColor(hex: "FF9414"))
        let bottom = Color(UIColor(hex: "FF1452"))
        let gradient = Gradient(colors: [top, bottom])
        return LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }
}


struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(onDismiss: {})
    }
}
