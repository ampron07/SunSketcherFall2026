//
//  MainScreen.swift
//  Sunsketcher
//
//  Created by Ferguson, Tameka on 1/25/24.
//

/*
 This is the main screen of the app. This is where the client get its client ID from the server.
 I've implemented a lot of UserDefaults preferences to keep track of the state of the app and of the functions.
 */



import SwiftUI
import AVFoundation
import Photos
import CoreLocation
import UserNotifications


struct MainScreen: View {
    let prefs = UserDefaults.standard
    var isTutorialDone = false
//    var socket = Socket()
    
    @ObservedObject var viewModel: MainScreenModel
    @State private var shouldRefreshView = false 
    
    @StateObject private var locationManager = LocationManager()
    @State private var isPermissionRequested = false
    //var main = SunSketcherApp()
    
    //@State private var clientIDobtained = false
    @State private var backgroundTask: BackgroundTask?
    
    @State var photoCaptureDone = false // Keeps the state of photo captures
    
    var body: some View {
        if !photoCaptureDone{
            GeometryReader { geo in
                NavigationStack () {
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
                        
                        // For buttons
                        ZStack {
                            // For start button
                           
                            if viewModel.isFinished {
                                NavigationLink(destination: LocationVerification(), label: {
                                    Text("Start")
                                        .font(Font.custom("Montserrat-SemiBold", size: geo.size.width * 0.12))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(width: geo.size.width * 0.66, height: geo.size.height * 0.078)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.87, green: 0.58, blue: 0.09), Color(red: 0.10, green: 0.13, blue: 0.47).opacity(0)]), startPoint: .bottom, endPoint: .top)
                                        ).clipShape(RoundedRectangle(cornerRadius: geo.size.width * 0.04))
                                        .overlay(RoundedRectangle(cornerRadius: geo.size.width * 0.04)
                                            .inset(by: -geo.size.width * 0.01)
                                            .strokeBorder(.white, lineWidth: geo.size.width * 0.008))
                                })// For navigation link
                                .frame(width: geo.size.width * 0.62, height: geo.size.height * 0.16)
                                .offset(x: 0, y: -geo.size.height * 0.25)
                            } else {
                                NavigationLink(destination: SeeOrSkipTutorial(shouldRefreshView: $shouldRefreshView), label: {
                                    Text("Start")
                                        .font(Font.custom("Montserrat-SemiBold", size: geo.size.width * 0.12))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(width: geo.size.width * 0.66, height: geo.size.height * 0.078)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.87, green: 0.58, blue: 0.09), Color(red: 0.10, green: 0.13, blue: 0.47).opacity(0)]), startPoint: .bottom, endPoint: .top)
                                        ).clipShape(RoundedRectangle(cornerRadius: geo.size.width * 0.04))
                                        .overlay(RoundedRectangle(cornerRadius: geo.size.width * 0.04)
                                            .inset(by: -geo.size.width * 0.01)
                                            .strokeBorder(.white, lineWidth: geo.size.width * 0.008))
                                })// For navigation link
                                .frame(width: geo.size.width * 0.62, height: geo.size.height * 0.16)
                                .offset(x: 0, y: -geo.size.height * 0.25)
                            }
                            
                            // For tutorial button
                            NavigationLink(destination: TutorialScreen1(shouldRefreshView: $shouldRefreshView), label: {
                                Text("Tutorial")
                                    .font(Font.custom("Montserrat-SemiBold", size: geo.size.width * 0.12))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .frame(width: geo.size.width * 0.66, height: geo.size.height * 0.078)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.87, green: 0.58, blue: 0.09), Color(red: 0.10, green: 0.13, blue: 0.47).opacity(0)]), startPoint: .bottom, endPoint: .top)
                                    ).clipShape(RoundedRectangle(cornerRadius: geo.size.width * 0.04))
                                    .overlay(RoundedRectangle(cornerRadius: geo.size.width * 0.04)
                                        .inset(by: -geo.size.width * 0.01)
                                        .strokeBorder(.white, lineWidth: geo.size.width * 0.008))
                            })// For navigation link
                            .frame(width: geo.size.width * 0.62, height: geo.size.height * 0.16)
                            .offset(x: 0, y: -geo.size.height * 0.10)
                            
                            // For Learn More button
                            NavigationLink(destination: LearnMoreScreen1(), label: {
                                Text("Learn More")
                                    .font(Font.custom("Montserrat-SemiBold", size: geo.size.width * 0.1))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .frame(width: geo.size.width * 0.66, height: geo.size.height * 0.078)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.87, green: 0.58, blue: 0.09), Color(red: 0.10, green: 0.13, blue: 0.47).opacity(0)]), startPoint: .bottom, endPoint: .top)
                                    ).clipShape(RoundedRectangle(cornerRadius: geo.size.width * 0.04))
                                    .overlay(RoundedRectangle(cornerRadius: geo.size.width * 0.04)
                                        .inset(by: -geo.size.width * 0.01)
                                        .strokeBorder(.white, lineWidth: geo.size.width * 0.008))
                            })// For navigation link
                            .frame(width: geo.size.width * 0.62, height: geo.size.height * 0.16)
                            .offset(x: 0, y: -geo.size.height * 0)
                            .padding(.top, geo.size.height * 0.1)
                            
                            VStack {
                                NavigationLink(destination: TermAndConditions()) {
                                    Text("Terms and Conditions")
                                    
                                }.frame(height: geo.size.height, alignment: .bottom)
                            }
                            
                        }// For ZStack
                    }// For the Zstack
                }// For the navigation stack
                .navigationBarBackButtonHidden(true)
                .onAppear(perform: {
                    viewModel.updateIsFinished()
                    if !isPermissionRequested {
                        requestPermissions()
                    }
                    
                    let metadataArray = MetadataDB.shared.retrieveImageMeta()
                    let arrayCount = metadataArray.count
                    print(arrayCount)
                    
                    // This checks if there are any photo entries in the database. If there is and somehow the user got back to the main screen, it will redirect them to the SharePhotos screen.
                    if arrayCount > 0 {
                        print("Array count greater than 0")
                        photoCaptureDone = true
                    } /*else {
                        // Create a background task to handle getting client ID
                        backgroundTask = BackgroundTask { task in
                            // If the client ID is not obtained yet we want the client to keep trying.
                            if (!prefs.bool(forKey: "ClientID obtained") && !prefs.bool(forKey: "Requesting")) || (prefs.integer(forKey: "ClientID") < 0) {
                                
                                prefs.set(true, forKey: "Requesting")
                                
                                // Retry logic with exponential backoff
                                var retryCount = 0
                                // This was created to make sure that the client would have enough time to get an ID
                                let maxWaitTime = 20.0 // Maximum wait time between retries (in seconds)
                                
                                
                                retryGetClientID()
                                
                                func scheduleNextRetry() {
                                    let waitTime = min(pow(10.0, Double(retryCount)), maxWaitTime)
                                    DispatchQueue.global().asyncAfter(deadline: .now() + waitTime) {
                                        if !prefs.bool(forKey: "ClientID obtained") {
                                            print("Getting CliendID")
                                            getClientID()
                                            
                                            if !prefs.bool(forKey: "ClientID obtained") {
                                                print("Called")
                                                retryGetClientID()
                                            }else {
                                                print("ID received, cancel background task")
                                                task.setTaskCompleted(success: true)
                                                backgroundTask?.cancel()
                                            }
                                        }else {
                                            print("ID received, cancel background task")
                                            task.setTaskCompleted(success: true)
                                            backgroundTask?.cancel()
                                        }
                                    }
                                }
                                
                                func retryGetClientID() {
                                    retryCount += 1
                                    
                                    print("Get Client ID (Attempt \(retryCount))")
                                    scheduleNextRetry()
                                    
                                }
                                
                            } else {
                                print("ID received, cancel background task")
                                task.setTaskCompleted(success: true)
                                backgroundTask?.cancel()
                            }
                            
                            
                        }
                        self.prefs.set(false, forKey: "Transfer complete")
                        self.prefs.set(false, forKey: "Transfer called")
                        self.prefs.set(false, forKey: "Socket open")
                    }*/
                    
                })
                .onChange(of: shouldRefreshView) { _ in // Refresh view when shouldRefreshView changes
                    viewModel.updateIsFinished()
                }
            }// For geometry
        } else {
            //ImageScrollView()
            AfterPhotosReceived()
        }
        
    }// For body
    
     
    
    private func requestPermissions() {
        // Request location permission
        locationManager.requestLocationPermission()
            // Request result printed in LocationManager
        
        // Request camera permission
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                // Camera permission granted
                print("Camera permission granted")
            } else {
                // Camera permission denied
                print("Camera permission denied")
            }
        }
        
        // Request photo library permission
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                // Photo library permission granted
                print("Photo library permission granted")
            case .denied, .restricted:
                // Photo library permission denied
                print("Photo library permission denied")
            case .notDetermined:
                // The user hasn't made a choice yet
                print("Photo library permission not determined")
            default:
                break
            }
        }
        
        // Request notification permissions
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Notifications allowed.")
            case .denied:
                print("Notifications denied")
            case .notDetermined:
                print("Notifications not determined")
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        return
                    }
                    
                }
            default:
                break
            }
        }
        
        isPermissionRequested = true
    }
    
    
    /*func getClientID() {
        let idRequest = UnsecureTransfer()
        let idReqStatus = idRequest.IDRequest()
        return
    }*/

}

/*struct ImageScrollView: View {
    var body: some View {
        SharePhotos()
    }
}*/


//struct MainScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        MainScreen(viewModel: MainScreenModel())
//            .environmentObject(LocationManager())
//    }
//}
