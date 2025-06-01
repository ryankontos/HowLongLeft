//
//  File.swift
//  
//
//  Created by Ryan on 18/6/2024.
//

import Foundation
import CoreLocation

import Foundation
import CoreLocation

final public class LocationCache {
    private var cache: [String: CLLocation] = [:]
    
    func getLocation(for name: String) -> CLLocation? {
        return cache[name]
    }
    
    func setLocation(_ location: CLLocation, for name: String) {
        cache[name] = location
    }
}

@MainActor
final public class LocationConverter {
    static public let shared = LocationConverter()
   
    private let cache = LocationCache()
    
    private init() {}
    
    public func convertToCLLocation(locationName: String) async throws -> CLLocation {
        // Check if the location is already in the cache
        if let cachedLocation = cache.getLocation(for: locationName) {
            return cachedLocation
        }
        
        
        let geocoder = CLGeocoder()
        // Perform geocoding
        let placemarks = try await geocoder.geocodeAddressString(locationName)
        
        guard let placemark = placemarks.first, let location = placemark.location else {
            throw NSError(domain: "LocationConverter", code: 0, userInfo: [NSLocalizedDescriptionKey: "Location not found"])
        }
        
        // Cache the location
        cache.setLocation(location, for: locationName)
        
        return location
    }
}
