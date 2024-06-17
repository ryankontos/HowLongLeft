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
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack(alignment: .center) {
                        
                          RoundedRectangle(cornerRadius: 10)
                            .frame(width: 4.5)
                            .foregroundColor(getColor())
                        
                        Text("\(event.title)")
                            .font(.system(size: 15.25, weight: .medium, design: .default))
                        
                       
                        
                        Spacer()
                        
                    }
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                    if let locationName = event.locationName {
                        Text(locationName)
                    }
                    
                }
                
                Spacer()
                
              
                if let region = mapLocation {
                    
                    Map(coordinateRegion: .constant(region), interactionModes: [], showsUserLocation: false, userTrackingMode: .constant(.none), annotationItems: annotationItems, annotationContent: { item in
                        MapMarker(coordinate: item.coordinate, tint: getColor())
                    })
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                }
                
            }
           
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .frame(width: 270, height: 350)
            
        }
        .onAppear() {
            setLocation()
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
    
    return MenuEventView(event: .init(title: "[Maxim Street Health Hub] Reception", start: Date(), end: Date().addingTimeInterval(10)))
        .environmentObject(container.calendarReader)
        .environmentObject(ModernMenuBarExtraWindow(title: "Title", content: {
            AnyView(Text("Content"))
        }))
    
    
}

struct MapAnnotationItem: Identifiable {
    var coordinate: CLLocationCoordinate2D
    let id = UUID()
}
