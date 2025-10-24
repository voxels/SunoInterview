//
//  PagingView.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/24/25.
//


import SwiftUI

struct PagingView : View {
    @Binding public var clips:[Clip]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .center) {
                    ForEach(clips, id: \.self) { clip in
                        ZStack(alignment: .center) {
                            BackgroundContentView(clip: clip)
                                .frame(width:geometry.size.width, height:geometry.size.height)
                            InfoView(clip: clip)
                        }
                     }
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.visible)
        }
    }
}
