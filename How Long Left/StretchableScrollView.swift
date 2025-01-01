import SwiftUI

@MainActor
struct StretchableScrollView<BackgroundView: View, TopContentView: View, BottomView: View>: View {
    let backgroundView: BackgroundView
    let topContentView: TopContentView
    let bottomView: BottomView
    let topViewHeight: CGFloat

    @State private var scrollOffset: CGFloat = 0.0

    init(
        topViewHeight: CGFloat,
        @ViewBuilder backgroundView: () -> BackgroundView,
        @ViewBuilder topContentView: () -> TopContentView,
        @ViewBuilder bottomView: () -> BottomView
    ) {
        self.topViewHeight = topViewHeight
        self.backgroundView = backgroundView()
        self.topContentView = topContentView()
        self.bottomView = bottomView()
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Stretchable background view
            GeometryReader { geometry in
                let stretchHeight = max(topViewHeight + (-scrollOffset), topViewHeight)

                backgroundView
                    .frame(height: stretchHeight)
                    .clipped() // Prevents unnecessary overflow
                    .edgesIgnoringSafeArea(.top)
            }
            .frame(height: topViewHeight)

            // Scrollable content
            ScrollView {
                GeometryReader { innerGeometry in
                    let offset = innerGeometry.frame(in: .global).minY
                    Color.clear
                        .onChange(of: offset) { _, newValue in
                            scrollOffset = newValue
                        }
                }
                .frame(height: 0) // Invisible frame to track offset

                VStack(spacing: 0) {
                    // Top content view scrolls with content
                    topContentView
                        .frame(height: topViewHeight)

                    // Bottom content starts below the top content
                    bottomView
                        .background(Color.white)
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .shadow(radius: 5)
                }
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
