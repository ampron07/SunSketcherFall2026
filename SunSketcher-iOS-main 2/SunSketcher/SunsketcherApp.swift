//
//  SunSketcherApp.swift
//  SunSketcher
//
//  Created by Tameka Ferguson on 8/25/23.
//

// This the main .swift file for the app.
// In the views, GeometryReader is used because we want the app to be optimized for different screen sizes so this adjusts all of the measurements to accommodate the screen.

import SwiftUI


@main
struct SunSketcherApp: App {
    @StateObject var locationManager = LocationManager()
    let metadataDB = MetadataDB.shared
    
    let preferences = UserDefaults.standard
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .environmentObject(locationManager)
        }
    }
    
        func convertTimes(data: [String]) -> [Int64] {
            let start = data[0].split(separator: ":").compactMap { Int($0) }
            let end = data[1].split(separator: ":").compactMap { Int($0) }

            // Add the actual time to the Unix time of UTC midnight for the start of that day
            // For August 12, 2026
            let startUnix = 1786528800-36000 + (Int64(start[0]) * 3600) + (Int64(start[1]) * 60) + Int64(start[2]) // Noon Spain + Start Time - 10 Hours
            let endUnix = 1786528800-36000 + (Int64(end[0]) * 3600) + (Int64(end[1]) * 60) + Int64(end[2])

            return [startUnix, endUnix]
        }
    
    // convert `hh:mm:ss` format string to unix time (this version is specifically for Aug. 21, 2017 eclipse)
        /*func convertTimes(data: [String]) -> [Int64] {
            let start = data[0].split(separator: ":").compactMap { Int($0) }
            let end = data[1].split(separator: ":").compactMap { Int($0) }

            // Add the actual time to the Unix time of UTC midnight for the start of that day
            // For August 21, 2017
            let startUnix = 1503273600 + (Int64(start[0]) * 3600) + (Int64(start[1]) * 60) + Int64(start[2])
            let endUnix = 1503273600 + (Int64(end[0]) * 3600) + (Int64(end[1]) * 60) + Int64(end[2])

            return [startUnix, endUnix]
        }*/
        
    
    // convert `hh:mm:ss` format string to unix time (this version is specifically for Apr. 8, 2024 eclipse)
    /*func convertTimes(data: [String]) -> [Int64] {
        let start = data[0].split(separator: ":").compactMap { Int($0) }
        let end = data[1].split(separator: ":").compactMap { Int($0) }

        // Add the actual time to the Unix time of UTC midnight for the start of that day
        // For April 8
        let startUnix = 1712534400 + (Int64(start[0]) * 3600) + (Int64(start[1]) * 60) + Int64(start[2])
        let endUnix = 1712534400 + (Int64(end[0]) * 3600) + (Int64(end[1]) * 60) + Int64(end[2])

        return [startUnix, endUnix]
    }*/
    
}

