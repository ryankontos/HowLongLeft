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
    var menuModel: WindowSelectionManager!
    var event: Event
    
    
    
    init(event: Event) {
        self.event = event
        self.menuModel = WindowSelectionManager(itemsProvider: self)
        
  
        
    }
    
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
                            
                            
                            
                            EventInfoItemView(symbol: "location.fill", color: .blue) {
                                Text("Room: 10")
                            }
                            
                            EventInfoItemView(symbol: "clock.fill", color: .purple) {
                                VStack(alignment: .leading) {
                                    
                                    Text("Today, 12:00am -")
                                    Text("Today, 1pm")
                                    
                                }
                            }
                            
                            EventInfoItemView(symbol: "hourglass", color: .green) {
                                VStack(alignment: .leading) {
                                    
                                    Text("1 hour")
                                    
                                    
                                }
                            }
                            
                            EventInfoItemView(symbol: "calendar", color: .red) {
                                VStack(alignment: .leading) {
                                    
                                    Text("Home")
                                    
                                    
                                }
                            }
                         
                            
                            
                        }
                        .padding(.top, 6)
                        
                            
                            
                        
                        
                        Spacer()
                        
                        if let region = mapLocation {
                            
                            Divider()
                                .padding(.vertical, 10)
                            
                            Map(coordinateRegion: .constant(region), interactionModes: [], showsUserLocation: false, userTrackingMode: .constant(.none), annotationItems: annotationItems, annotationContent: { item in
                                MapMarker(coordinate: item.coordinate, tint: getColor())
                            })
                            .allowsHitTesting(false)
                            .frame(height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        }
                        
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    
                   // .frame(minHeight: 250)
                }
                
                
                VStack(spacing: 2) {
                    
                    Divider()
                        .padding(.bottom, 6)
                    
                   
                    MenuButton(model: menuModel, idForHover: "2", padding: 4, content: {
                        HStack {
                           
                            Text("Options...")
                            Spacer()
                           
                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .regular))
                        }
                    }, action: {
                        
                    })
                    
                    
                }
                
            }
           
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .frame(width: 270, height: 280)
            
        }
        .onAppear() {
            setLocation()
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
               // .background(Color.red)
                
                HStack(spacing: 5) {
                    
                    Image(systemName: "timer")
                       
                    
                    Text("5 minutes remaining")
                        
                    // .padding(.leading, 10)
                    
                }
                .font(.system(size: 13.5, weight: .medium, design: .default))
                .foregroundStyle(.secondary)
                .opacity(0.75)
                
            }
          
            
        }
        
        
    }
    
    func getColor() -> Color {
        
        if let cg = calSource.lookupCalendar(withID: event.calId)?.cgColor {
            return Color(cg)
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
        return ["1","2"]
    }
    
    
}

#Preview {
    
    let container = MacDefaultContainer()
    
    return MenuEventView(event: .init(title: "Reception", start: Date(), end: Date().addingTimeInterval(10)))
        .environmentObject(container.calendarReader)
        .environmentObject(ModernMenuBarExtraWindow(title: "Title", content: {
            AnyView(Text("Content"))
        }))
    
    
}

struct MapAnnotationItem: Identifiable {
    var coordinate: CLLocationCoordinate2D
    let id = UUID()
}
