import SwiftUI
import HowLongLeftKit

struct MainView: View {

    @EnvironmentObject private var pointStore: TimePointProviderWrapper
    @State private var selection = 0

    private var inProgressEvents: [HLLEvent] {
        pointStore.currentPoint?.inProgressEvents ?? []
    }

    private let cardHeight: CGFloat = 240
    private let indicatorHeight: CGFloat = 30

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let cardWidth = proxy.size.width - 20

                ScrollView {
                    
                    
                    VStack(spacing: 0) {
                        
                        HStack {
                            Text("On Now")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 20, weight: .semibold))
                                
                                
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        VStack() {
                            
                            TabView(selection: $selection) {
                                ForEach(Array(inProgressEvents.enumerated()), id: \.1.id) { idx, event in
                                    
                                   
                                        
                                        CurrentCard(event: event)
                                            .padding(.vertical, )
                                            .tag(idx)
                                            .frame(width: cardWidth)
                                            
                                           
                                           
                                        
                                  
                                   
                                }
                            }
                            //.background(Color.green)
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(height: 250)
                            .padding(.top, 17)
                           
                            
                            // 2) Our custom UIPageControl, sitting *below* the cards
                            PageControl(
                                numberOfPages: inProgressEvents.count,
                                currentPage: $selection
                            )
                            .frame(height: indicatorHeight)
                            
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 25)
                }
                .navigationTitle("How Long Left")
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(TimePointProviderWrapper.dummy(empty: false))
}
