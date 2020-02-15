//
//  OnboardView.swift
//  FNote
//
//  Created by Dara Beng on 2/13/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct OnboardView: View {
    
    @State private var viewModel = OnboardCollectionViewModel()
    @State private var currentPage = 0
    
    @State private var viewBGColor = Color.clear
    @State private var hasShownLastPage = false
    
    var onDismiss = {}
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            CollectionViewWrapper(viewModel: _viewModel.wrappedValue)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                if hasShownLastPage {
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
        .overlay(dismissButton, alignment: .topTrailing)
        .overlay(dragHandle.padding(.top, 8), alignment: .top)
        .background(viewBGColor.edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.horizontal)
        .onAppear(perform: setupOnAppear)
    }
}


extension OnboardView {
    
    func setupOnAppear() {
        viewModel.onPageChanged = handlePageChanged
    }
    
    func handlePageChanged(pageIndex: Int, page: OnboardPage) {
        viewBGColor = Color(UIColor(hex: page.backgroundColor))
        currentPage = pageIndex
        if pageIndex == viewModel.pages.count - 1 {
            hasShownLastPage = true
        }
    }
    
    func setupPageControl(_ control: UIPageControl) {
        control.isUserInteractionEnabled = false
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        control.transform = .init(scaleX: 1.2, y: 1.2)
    }
}


extension OnboardView {
    
    var dismissButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .frame(width: 50, height: 50)
        }
        .accentColor(.black)
        .opacity(hasShownLastPage ? 1 : 0)
    }
    
    var dragHandle: some View {
        ModalDragHandle(color: .black, hideOnLandscape: true)
    }
}


struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
    }
}
