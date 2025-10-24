import SwiftUI

struct PagingView : View {
    @Binding public var imageURLs:[SongMetadata]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .center) {
                    ForEach(imageURLs, id: \.self) { url in
                        ZStack(alignment: .center) {
                            BackgroundContentView(imageMetadata: url)
                                .frame(width:geometry.size.width, height:geometry.size.height)
                            InfoView(imageMetadata: url)
                        }
                     }
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.visible)
        }
    }
}