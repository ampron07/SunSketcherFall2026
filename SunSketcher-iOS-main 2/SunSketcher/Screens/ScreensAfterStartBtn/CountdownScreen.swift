//
//  CountdownScreen.swift
//  Sunsketcher
//
//  Created by Ferguson, Tameka on 3/11/24.
//


// This view specifically deals with both countdown screens.



import SwiftUI

struct CountdownScreen: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    var main = SunSketcherApp()
    
    @State private var countdownTimeString: String = ""
    @State private var timer: Timer?
    @State var countdownTimeDiff: Int64 = 0
   
    let prefs = UserDefaults.standard
    @State var countdownDone = false
    @State private var isPresented: Bool = false
    
    @State private var isScreen1 = true
    @State private var isScreen2 = false
    
    var body: some View {
        
        // This if statement is used to change the view to the camera once the countdown timer hits 0.
        if !countdownDone {
            GeometryReader { geo in
                NavigationStack {
                    ZStack {
                        // For background
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .background(Color(red: 0.04, green: 0.04, blue: 0.03))
                            .offset(x: 0, y: 0)
                        
                        // For logo
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.14)
                            .background(
                                Image("img-logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.07)
                                    .clipped()
                                
                            )
                            .offset(x: 0, y: -geo.size.height * 0.45)
                            .padding(.top, 20)
                        
                        // For eclipse image
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geo.size.width * 0.85, height: geo.size.height * 1)
                            .background(
                                Image("img-eclipse")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geo.size.width * 1, height: geo.size.height * 1.4)
                                
                            )
                            .offset(x: 0, y: geo.size.height * 0.22)
                        
                       
                        VStack {
                            // This is for the top white line of the background overlay
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: geo.size.width, height: geo.size.height * 0.004)
                                .background(Color(red: 1, green: 1, blue: 1))
                                .padding(.top, geo.size.height * 0.11)
                            ZStack {
                                // For dark somewhat clear background overlay
                                Color.black.opacity(0.4)
                                    .frame(width: geo.size.width * 1, height: geo.size.height * 0.8)
                                    .offset(x: 0, y: geo.size.height * 0.03)
                                
                                VStack {
                                    
                                    if isScreen1 {
                                        ScrollView {
                                            Text("Your location: Latitude: \(locationManager.location?.coordinate.latitude ?? 0.0) | Longitude: \(locationManager.location?.coordinate.longitude ?? 0.0)")
                                                .font(Font.custom("Montserrat", size: geo.size.width * 0.04)
                                                        .weight(.bold)
                                                )
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .offset(x: 0, y: geo.size.height * 0.0)
                                        }.frame(width: geo.size.width * 0.9, height: geo.size.height * 0.05)
                                        
                                        
                                        
                                        
                                        // For DND image
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: geo.size.width * 0.55, height: geo.size.height * 0.24)
                                            .background(
                                                Image("img-dnd")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: geo.size.width * 0.83, height: geo.size.height * 0)
                                            )
                                            .overlay(
                                                Rectangle()
                                                    .stroke(.white, lineWidth: 0)
                                            )
                                        
                                        ScrollView {
                                            Text("Please turn your ringer off and Do Not Disturb on!")
                                                .font(
                                                    Font.custom("Montserrat", size: geo.size.width * 0.075)
                                                        .weight(.semibold)
                                                )
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                        }.frame(width: geo.size.width * 0.9, height: geo.size.height * 0.19)
                                        
                                        
                                    } else if isScreen2 {
                                        Image("img-phonestand")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.2)
                                            .padding(.top, geo.size.height * 0.008)
                                        
                                        ScrollView {
                                            Text("Set the phone with the REAR CAMERA facing the Sun. Enjoy totality, come back in 10 minutes!")
                                                .font(
                                                    Font.custom("Montserrat", size: geo.size.width * 0.07)
                                                        .weight(.semibold)
                                                )
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                                .frame(width: geo.size.width * 0.9)
                                                .padding(.top, geo.size.height * 0.035)
                                        }.frame(width: geo.size.width * 1, height: geo.size.height * 0.28)
                                        
                                        
                                    }
                                    
                                    ScrollView {
                                        Text(countdownTimeString)
                                            .font(
                                                Font.custom("Montserrat", size: geo.size.width * 0.07)
                                                    .weight(.bold)
                                            )
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.top, geo.size.height * 0.00)
                                    }.frame(width: geo.size.width * 1, height: geo.size.height * 0.1)
                                    
                                    
                                    // These if/else if statements are for the arrow buttons at the bottom of the screen
                                    if isScreen1 {
                                        Button(action: {
                                            // If the right arrow is clicked, this sets the isScreen1 to false and isScreen2 to true which hides
                                            // everything seen on the first countdown screen and reveals everything seen on the second countdown screen.
                                            isScreen1 = false
                                            isScreen2 = true
                                        }) {
                                            Image("ic-rightarrow")
                                                .frame(width: geo.size.width * 0.14, height: geo.size.width * 0.13)
                                                .padding(.leading, geo.size.width * 0.72)
                                        }
                                        
                                    } else if isScreen2 {
                                        Button(action: {
                                            isScreen1 = true
                                            isScreen2 = false
                                        }) {
                                            Image("ic-leftarrow")
                                                .frame(width: geo.size.width * 0.10, height: geo.size.width * 0.08)
                                                .padding(.trailing, geo.size.width * 0.71)
                                                .offset(x: geo.size.width * 0.0, y: geo.size.height * 0.01)
                                        }
                                    }
                                    
                                }// Vstack
                            }// zstack
                            
                            // This is for the bottom white line of the background overlay
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: geo.size.width, height: geo.size.height * 0.004)
                                .background(Color(red: 1, green: 1, blue: 1))
                                .padding(.top, geo.size.height * 0.016)
                            
                        }// For Vstack
                    }// For Zstack
                }// For navigation stack
                .navigationBarBackButtonHidden()
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    getLocation(locationMan: locationManager) // TODO: For actual release
                }
            }// For geometry
        } else {
            CameraScreen()
        }
    }// For body
    
    private func getLocation(locationMan: LocationManager) {
        
        let lat = locationMan.location?.coordinate.latitude ?? 0.0
        let lon = locationMan.location?.coordinate.longitude ?? 0.0
        let alt = locationMan.location?.altitude ?? 0.0
        
        // Declare the LocToTime
        let locToTime: LocToTime = LocToTime()
        
        // TODO: for actual release
        // Gets the start and end times of the eclipse based on the lat, lon and alt
        let eclipseData: [String] = locToTime.calculatefor(lat: lat, lon: lon, alt: alt);
        
        print("Eclipse data \(eclipseData)")
        
        
        // The eclipseData is going to be in an array String
        // Makes sure the user is in the eclipse path
        if eclipseData[0] != "N/A" {
            let times = main.convertTimes(data: eclipseData)
            print("Start time: \(times[0]) \n End time: \(times[1])")
            
            // Create a countdown timer here that will be passed to a swiftui view
            countdownTimeDiff = ((times[0]) - 60) - (Int64(Date().timeIntervalSince1970))
            
            print("Date:", Date().formatted())
            print("Countdown Diff Time: \(countdownTimeDiff)")
            
            
            // store the unix time for the start and end of totality in UserDefaults
            let prefs = UserDefaults.standard
            prefs.set(Int(times[0] * 1000), forKey: "startTime")
            prefs.set(Int(times[1] * 1000), forKey: "endTime")
            prefs.set(Float(lat), forKey: "lat")
            prefs.set(Float(lon), forKey: "lon")
            prefs.set(Float(alt), forKey: "alt")
            
            print("\(times[0] * 1000)")
            print("\(times[1] * 1000)")
            print("\(Float(lat))")
            print("\(Float(lon))")
            print("\(Float(alt))")
            
            startTimer()
            
        } else {
            // Do something if the user isn't in the eclipse path
            countdownTimeString = "You're not in the path of totality."
            print("Not in totality path.")
        
            
        }
    }
    
    
    /* Starts a countdown timer that updates every second and tracks the time remaining.
     The timer decrements a `countdownTimeDiff` property and updates a formatted string `countdownTimeString`
     to display the remaining time in the format `HH:mm:ss UNTIL FIRST PHOTO IS TAKEN`.
     If the countdown reaches zero, the timer is invalidated, and certain actions are performed (e.g., updating a flag and user preferences).
     */
    private func startTimer() {
        timer?.invalidate() // Invalidate any existing timer to ensure only one timer is running at a time.
        
        // Check if there is remaining countdown time.
        if countdownTimeDiff > 0 {
            // Schedule a repeating timer to fire every second.
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                
                DispatchQueue.global().async {
                    self.countdownTimeDiff -= 1 // Decrement the time difference by 1 second
                    
                    if self.countdownTimeDiff > 0 {
                        // Calculate hours, minutes, and seconds from the remaining time.
                        let hours = self.countdownTimeDiff / 3600
                        let minutes = (self.countdownTimeDiff % 3600) / 60
                        let seconds = self.countdownTimeDiff % 60
                        
                        // Update the countdown string on the main thread to reflect the time remaining.
                        DispatchQueue.main.async{
                            self.countdownTimeString = String(format: "%02d:%02d:%02d UNTIL FIRST PHOTO IS TAKEN", hours, minutes, seconds)
                        }
                    } else {
                        self.stopTimer()
                        print("Timer stopped")
                        self.countdownDone = true
                        self.prefs.set(false, forKey: "Photos complete")
                    }
                }
            }
        } else {
            countdownTimeString = "The total eclipse has already started at your location."
        }
    }
    
    // TODO: for testing
    /*private func startTimerTesting() {
        timer?.invalidate()
        
        let oneMinuteInMillis = 13 * 1000 // 1 minute in milliseconds
        let currentTimeMillis = Int(Date().timeIntervalSince1970 * 1000)
        let targetTime = currentTimeMillis + oneMinuteInMillis
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let currentTimeMillis = Int(Date().timeIntervalSince1970 * 1000)
            let millisecondsLeft = (targetTime - currentTimeMillis)
            
            if millisecondsLeft > 0 {
                let secondsLeft = millisecondsLeft / 1000
                let hours = secondsLeft / 3600
                let minutes = (secondsLeft % 3600) / 60
                let seconds = secondsLeft % 60
                countdownTimeString = String(format: "%02d:%02d:%02d UNTIL FIRST PHOTO IS TAKEN", hours, minutes, seconds)
            } else {
                countdownTimeString = "Countdown Ended"
                stopTimer()
                print("Timer stopped")
                countdownDone = true
                
                let startTime = currentTimeMillis + 30000  //TODO: remove for actual app rele ases
                let endTime = startTime + (60000 * 5) + 5  //5 minutes after startTime TODO: remove for actual app releases
                
                let lat = 28.333333
                let lon = -78.333333
                let alt = locationManager.location?.altitude ?? 0.0
                
                prefs.set(Float(lat), forKey: "lat")
                prefs.set(Float(lon), forKey: "lon")
                prefs.set(Float(alt), forKey: "alt")
                prefs.set(startTime, forKey: "startTime")
                prefs.set(endTime, forKey: "endTime")
                
                print("Start time: \(startTime), endTime: \(endTime)")
                
                return
            }
        }
    }*/

    
    private func stopTimer() {
        timer?.invalidate()
    }
}

struct CameraScreen: View {
    
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        
        CustomCameraView(capturedImage: $capturedImage)
            .navigationBarBackButtonHidden(true)
    }
    
}

struct CountdownScreen_Previews: PreviewProvider {
    static var previews: some View {
        CountdownScreen()
            .environmentObject(LocationManager())
    }
}
