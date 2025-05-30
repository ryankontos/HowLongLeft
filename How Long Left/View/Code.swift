import SwiftUI

// MARK: - Model --------------------------------------------------------------

struct CountdownEvent: Identifiable, Equatable {
    enum Category: String, CaseIterable {
        case work, personal, family
        
        var gradient: AngularGradient {
            switch self {
            case .work:     .init(gradient: .init(colors: [.purple,  .purple.opacity(0.35)]),  center: .center)
            case .personal: .init(gradient: .init(colors: [.orange,  .orange.opacity(0.35)]),  center: .center)
            case .family:   .init(gradient: .init(colors: [.green,   .green.opacity(0.35)]),   center: .center)
            }
        }
        var pillColour: Color {
            switch self {
            case .work:     .purple
            case .personal: .orange
            case .family:   .green
            }
        }
        var displayName: String { rawValue.capitalized }
    }
    
    let id = UUID()
    let title: String
    let start: Date
    let end: Date
    let category: Category
}

// MARK: - Glassmorphic modifier ----------------------------------------------

private struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var cornerRadius: CGFloat = 22
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: cornerRadius))
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(scheme == .dark ? 0.10 : 0.25),
                                .clear
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .blendMode(.plusLighter)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                (scheme == .dark ? Color.white : .black).opacity(0.15),
                                (scheme == .dark ? Color.white : .black).opacity(0.05)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1)
            )
            .shadow(color: .black.opacity(scheme == .dark ? 0.65 : 0.08),
                    radius: scheme == .dark ? 10 : 6, x: 0, y: scheme == .dark ? 8 : 4)
    }
}
extension View {
    func glassCardBackground(cornerRadius: CGFloat = 22) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Main view with hero transition -------------------------------------

struct ContentView: View {
    @State private var events: [CountdownEvent] = [
        .init(title: "Design Presentation",
              start: Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: .now)!,
              end:   Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: .now)!,
              category: .work),
        .init(title: "Dentist Appointment",
              start: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: .now)!,
              end:   Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: .now)!,
              category: .personal),
        .init(title: "Anniversary Dinner",
              start: Calendar.current.date(from: .init(year: 2025, month: 4, day: 24, hour: 19))!,
              end:   Calendar.current.date(from: .init(year: 2025, month: 4, day: 24, hour: 22))!,
              category: .personal),
        .init(title: "Family Reunion",
              start: Calendar.current.date(from: .init(year: 2025, month: 4, day: 28, hour: 13))!,
              end:   Calendar.current.date(from: .init(year: 2025, month: 4, day: 28, hour: 17))!,
              category: .family)
    ]
    
    // Hero namespace + selection
    @Namespace private var ns
    @State private var selected: CountdownEvent? = nil
    @State private var showDetails = false      // drives the secondary content fade
    
    var body: some View {
        ZStack {
            // Base list
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(events) { event in
                            CountdownCard(event: event)
                                .matchedGeometryEffect(id: event.id, in: ns, isSource: selected == nil)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                        selected = event
                                    }
                                    // delay the textual fade‑in slightly for polish
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                        showDetails = true
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                .navigationTitle("Countdowns")
                .navigationBarTitleDisplayMode(.large)
            }
            
            // Overlay when something is selected
            if let selected {
                ExpandedCard(event: selected,
                             showSecondary: $showDetails,
                             namespace: ns) {
                    // on dismiss
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        self.selected = nil
                        self.showDetails = false
                    }
                }
            }
        }
    }
}

// MARK: - Collapsed card (unchanged) -----------------------------------------

struct CountdownCard: View {
    let event: CountdownEvent
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let remaining = max(event.end.timeIntervalSince(ctx.date), 0)
            let progress  = 1 - remaining / event.end.timeIntervalSince(event.start)
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    pill
                    VStack(alignment: .leading, spacing: 7) {
                        title
                        timeLabel
                            .foregroundStyle(.secondary)
                    }
                        
                }
                Spacer(minLength: 12)
                CountdownRing(progress: progress,
                              remaining: remaining,
                              gradient: event.category.gradient)
            }
            .padding(20)
            .glassCardBackground()
        }
    }
    
    private var pill: some View {
        Text(event.category.displayName)
            .font(.caption.weight(.semibold))
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(Capsule().fill(event.category.pillColour))
            .foregroundStyle(.white)
    }
    private var title: some View {
        Text(event.title)
            .font(.system(size: 23, weight: .bold))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
    }
    private var timeLabel: some View {
        let df = DateFormatter()
        df.locale = .autoupdatingCurrent
        if Calendar.current.isDate(event.start, inSameDayAs: event.end),
           Calendar.current.isDateInToday(event.start) {
            df.dateFormat = "h:mm a"
            return Text("\(df.string(from: event.start)) – \(df.string(from: event.end))")
                .font(.system(size: 14.5, weight: .medium))
        } else {
            df.dateFormat = "d MMM, h:mm a"
            return Text("\(df.string(from: event.start)) – \(df.string(from: event.end))")
                .font(.system(size: 14.5, weight: .medium))
        }
    }
}

// MARK: - Expanded full‑screen card ------------------------------------------

private struct ExpandedCard: View {
    let event: CountdownEvent
    @Binding var showSecondary: Bool
    var namespace: Namespace.ID
    var onClose: () -> Void
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Hero background
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Placeholder detail blocks
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text("Here’s where you’d put the longer blurb, location, attendees, attachments – whatever floats your project boat.")
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        Text("– Bring mock‑ups\n– Double‑check animations\n– Print hand‑outs for the boss")
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Links")
                            .font(.headline)
                        Link("Browse Figma File", destination: URL(string: "https://example.com")!)
                    }
                }
                .padding()
                .opacity(showSecondary ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)                     // so the scroll doesn’t block taps
            .glassCardBackground(cornerRadius: 0)        // bleed to edges
            .matchedGeometryEffect(id: event.id, in: namespace) // hero
            
            // Close button
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.semibold))
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.top, 48).padding(.trailing, 24)
            .foregroundStyle(Color.primary)
            .opacity(showSecondary ? 1 : 0)
        }
        .ignoresSafeArea()
        .transition(.identity)       // rely solely on matchedGeometryEffect
        .zIndex(10)                  // stay above the list
        .onTapGesture {}             // swallow taps so list doesn’t receive them
    }
}

// MARK: - Countdown ring (unchanged) -----------------------------------------

struct CountdownRing: View {
    let progress: Double
    let remaining: TimeInterval
    let gradient: AngularGradient
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        ZStack {
            Circle()
                .stroke((scheme == .dark ? Color.white : Color.black).opacity(0.1),
                        lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: .init(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.2), value: progress)
            Text(remainingString)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(width: 75, height: 75)
    }
    private var remainingString: String {
        let hrs  = Int(remaining) / 3600
        let mins = (Int(remaining) % 3600) / 60
        let days = hrs / 24
        if days > 0 { return "\(days)d \(hrs % 24)h" }
        if hrs  > 0 { return "\(hrs)h \(mins)m" }
        return "\(mins)m"
    }
}

// MARK: - Preview -------------------------------------------------------------

#Preview {
    ContentView()
}
