import SwiftUI

struct AnimatedProgressBar: View {
    var progress: Double
    var color: Color
    var isFailed: Bool = false

    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(height: 10)
                    .foregroundColor(Color.gray.opacity(0.2))
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: geo.size.width * CGFloat(animatedProgress), height: 10)
                    .foregroundColor(isFailed ? .red : color)
                    .animation(.easeInOut(duration: 0.8), value: animatedProgress)
            }
            .onAppear {
                animatedProgress = progress
            }
            .onChange(of: progress) { newValue in
                animatedProgress = newValue
            }
        }
        .frame(height: 10)
    }
}
