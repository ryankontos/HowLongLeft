//
//  MenuEventView.swift
//  How Long Left Mac
//
//  Created by Ryan on 24/5/2024.
//

import SwiftUI
import HowLongLeftKit
import FluidMenuBarExtra
import MapKit

struct MenuEventView: View {

    @EnvironmentObject var calSource: CalendarSource
    @EnvironmentObject var eventInfoSource: StoredEventManager

    @EnvironmentObject var eventWindowManager: EventWindowManager
    
    var menuModel: WindowSelectionManager!
    var event: Event

    init(event: Event) {
        self.event = event
        self.menuModel = WindowSelectionManager(itemsProvider: self)

    }

    let formatter = DateFormatterUtility()

    @State var annotationItems: [MapAnnotationItem] = []

    @State var mapLocation: MKCoordinateRegion?

    var body: some View {

        ZStack {

            VStack {

                ScrollView(showsIndicators: false) {

                    VStack(alignment: .leading) {

                           headerView
                            .padding(.bottom, 6)

                            Divider()

                        VStack(alignment: .leading, spacing: 16) {

                            if let locationName = event.locationName {
                                EventInfoItemView(title: "Location", symbol: "location.fill", color: .blue) {
                                    Text(locationName)

                                }
                            }

                            EventInfoItemView(title: "Date", symbol: "clock.fill", color: .purple) {
                                VStack(alignment: .leading) {

                                    if event.isAllDay {
                                        Text("All-Day")
                                    }

                                    Text("\(formatter.getEventIntervalString(event: event, newLineForEnd: true))")

                                }
                            }

                            EventInfoItemView(title: "Duration", symbol: "hourglass", color: .green) {
                                VStack(alignment: .leading) {

                                    Text("1 hour")

                                }
                            }

                            EventInfoItemView(title: "Calendar", symbol: "calendar", color: .red) {
                                VStack(alignment: .leading) {

                                    Text("Home")

                                }
                            }

                        }
                        .padding(.top, 6)

                        Spacer()

                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)

                   // .frame(minHeight: 250)
                }

                VStack(spacing: 2) {

                    Divider()
                        .padding(.bottom, 6)

                    SubmenuButton(model: menuModel, idForHover: "1", padding: 4, content: {
                        HStack {

                            Text("Open in Window...")
                            Spacer()

                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .regular))
                        }
                    }, action: {

                        withAnimation {

                            eventWindowManager.openWindow(for: event)
                        }
                    })
                    
                    SubmenuButton(model: menuModel, idForHover: "2", padding: 4, content: {
                        HStack {

                            Text("Hide...")
                            Spacer()

                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .regular))
                        }
                    }, action: {

                        withAnimation {

                            eventInfoSource.addEventToStore(event: event)
                        }
                    })

                }

            }

            .padding(.vertical, 6)
            .padding(.bottom, 6)
            .padding(.horizontal, 10)
            .frame(width: 270, height: 300)

        }
        .onAppear {
          //  setLocation()
        }

    }

    var headerView: some View {

        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .center, spacing: 7) {
                    Circle()
                        .frame(width: 8)
                        .foregroundColor(getColor())

                    VStack(alignment: .leading, spacing: 5) {

                        Text("\(event.title)")
                            .font(.system(size: 14.5, weight: .medium, design: .default))
                            .opacity(0.9)

                    }

                    Spacer()

                    ProgressRingView(progress: 0.6, ringWidth: 4, ringSize: 22, color: getColor())

                }

                HStack(spacing: 5) {
                Image(systemName: "timer")

                EventCountdownText(event)

            }
                .font(.system(size: 13.5, weight: .medium, design: .default))
                .opacity(0.75)

            }

        }

    }

    func getColor() -> Color {

        if let cgCol = calSource.lookupCalendar(withID: event.calendarID)?.cgColor {
            return Color(cgCol)
        }

        return .blue

    }

    func setLocation() {

        Task {

            if let locationName = event.locationName {

                do {
                    let location = try await LocationConverter.shared.convertToCLLocation(locationName: locationName)

                    let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))

                    self.mapLocation = region

                    let item = MapAnnotationItem(coordinate: location.coordinate)

                    annotationItems = [item]

                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }

            }

        }

    }

}

extension MenuEventView: MenuSelectableItemsProvider {

    func getItems() -> [String] {
        return ["1", "2"]
    }

}

#Preview {

    let container = MacDefaultContainer(id: "MacPreview")

    let window = ModernMenuBarExtraWindow(title: "Title", content: {
        AnyView(Text("Content"))
    })

    MenuEventView(event: .init(title: "Reception", start: Date(), end: Date().addingTimeInterval(10)))
        .environmentObject(container.calendarReader)
        .environmentObject(window.proxy)

}

struct MapAnnotationItem: Identifiable {
    var coordinate: CLLocationCoordinate2D
    let id = UUID()
}
