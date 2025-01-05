//
//  MenuEventView.swift
//  How Long Left Mac
//
//  Created by Ryan on 24/5/2024.
//

import FluidMenuBarExtra
import HowLongLeftKit
import MapKit
import SwiftUI

@MainActor
struct MenuEventView: View {
    @EnvironmentObject var calSource: CalendarSource
    @EnvironmentObject var eventInfoSource: StoredEventManager

    @EnvironmentObject var eventWindowManager: EventWindowManager

    var statusItemPointStore: TimePointStore

    var menuModel: WindowSelectionManager!
    var event: HLLEvent

    init(event: HLLEvent, statusItemPointStore: TimePointStore) {
        self.event = event
        self.statusItemPointStore = statusItemPointStore
        self.menuModel = WindowSelectionManager(itemsProvider: self)
    }

    let formatter = DateFormatterUtility()

    @State private var annotationItems: [MapAnnotationItem] = []

    @State private var mapLocation: MKCoordinateRegion?

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
                            eventWindowManager.openWindow(for: event, withEventProvider: statusItemPointStore)
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

                    EventInfoText(event, stringGenerator: EventCountdownTextGenerator(showContext: true, postional: false))
                        
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

                    mapLocation = region

                    let item = MapAnnotationItem(coordinate: location.coordinate)

                    annotationItems = [item]
                } catch {
                    //print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension MenuEventView: MenuSelectableItemsProvider {
    func getItems() -> [String] {
        ["1", "2"]
    }
}



struct MapAnnotationItem: Identifiable {
    var coordinate: CLLocationCoordinate2D
    let id = UUID()
}
