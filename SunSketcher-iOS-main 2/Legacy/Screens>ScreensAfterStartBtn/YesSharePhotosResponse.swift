//
//  YesSharePhotosResponse.swift
//  Sunsketcher
//
//  Created by Ferguson, Tameka on 2/9/24.
//

import SwiftUI
import UserNotifications

extension Notification.Name {
    static let transferComplete = Notification.Name("TransferComplete")
}

struct YesSharePhotosResponse: View {
    @Environment(\.dismiss) private var dismiss
    let prefs = UserDefaults.standard
    @StateObject private var viewModel = AppViewModel()
    
    // used for switching views
    @State private var transferComplete = false
    
    @State private var timer: Timer?
    @State private var backgroundTask: BackgroundTask?
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack{
                ZStack {
                    if !transferComplete {
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
                                    .offset(x: 0, y: geo.size.height * 0.04)
                                
                                
                                VStack {
                                    Text("Thank you!")
                                        .font(
                                            Font.custom("Oswald", size: geo.size.width * 0.14)
                                                .weight(.semibold)
                                        )
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                        .frame(width: geo.size.width * 1, alignment: .top)
                                    ScrollView {
                                        Text("You have made a valuable contribution to science! To make sure your data is transmitted, please allow this app to run in the background (do not swipe up when viewing all open apps in the App Switcher) and do not uninstall the app until you are notified that it is safe to do so.\n\n You have made a valuable contribution to science! To make sure your data is transmitted, please do not uninstall the app until you are notified that it is safe to do so. \n\n Make it count! If you're a member of SciStarter, log your participation here to be included in #OneMillionActsofScience.")
                                            .font(
                                                Font.custom("Montserrat", size: geo.size.width * 0.05)
                                                    .weight(.semibold)
                                            )
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                    }.frame(width: geo.size.width * 0.9, height: geo.size.height * 0.4)
                                        .padding(.top, -geo.size.height * 0.05)
                                        .padding(.bottom, geo.size.width * 0)
                                    
                                    // SciStarter button
                                    Button(action: {
                                        if let url = URL(string: "https://scistarter.org/form/180") {
                                            UIApplication.shared.open(url)
                                        }
                                    }){
                                        HStack {
                                            Text("SciStarter Site")
                                            Image("ic-website")
                                        }.font(Font.custom("Montserrat", size: geo.size.width * 0.07))
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                            .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.08)
                                            .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.87, green: 0.58, blue: 0.09), Color(red: 0.10, green: 0.13, blue: 0.47).opacity(0)]), startPoint: .bottom, endPoint: .top)
                                            ).clipShape(RoundedRectangle(cornerRadius: geo.size.width * 0.04))
                                            .overlay(RoundedRectangle(cornerRadius: geo.size.width * 0.04)
                                                .inset(by: -geo.size.width * 0.01)
                                                .strokeBorder(.white, lineWidth: geo.size.width * 0.008))
                                    }
                                    
                                    // For Learn More button
                                    NavigationLink(destination: LearnMoreScreen1(), label: {
                                        Text("Learn More")
                                            .font(Font.custom("Montserrat-SemiBold", size: geo.size.width * 0.07))
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
                                    
                                    
                                    
                                }// VStack
                            }// ZStack
                            .padding(.top, geo.size.width * 0.01)
                            
                            // This is for the bottom white line of the background overlay
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: geo.size.width, height: geo.size.height * 0.004)
                                .background(Color(red: 1, green: 1, blue: 1))
                                .padding(.top, geo.size.height * 0.021)
                        }// VStack
                        
                    } else {
                        Finished()
                    }
                }//Zstack
                .onReceive(NotificationCenter.default.publisher(for: .transferComplete)) { _ in
                    transferDone()
                }
            }// Navigation stack
            .navigationBarBackButtonHidden()
            .onAppear {
                // I am setting these so that if the app is closed and reopened it will take the user to the correct screen they
                // should be on.
                viewModel.YesShareScreen = true
                viewModel.SharePhotosScreen = false
                
                // make sure to re-enable so that the app can sleep
                UIApplication.shared.isIdleTimerDisabled = false
                
                checkForPermissions()
                
                backgroundTask = BackgroundTask { task in
                    if !prefs.bool(forKey: "Transfer complete") && !prefs.bool(forKey: "Socket open") {
                        prefs.set(true, forKey: "Socket open")
                        
                        print("Starting transfer")
                        
                        var retryCount = 0
                        let maxWaitTime = 15.0 // Maximum wait time between retries (in seconds)
                        
                        // Initial data transfer attempt
                        dataTransfer()
                        
                        
                        func scheduleNextRetry() {
                            let waitTime = min(pow(10.0, Double(retryCount)), maxWaitTime)
                            DispatchQueue.global().asyncAfter(deadline: .now() + waitTime) {
                                if !prefs.bool(forKey: "Transfer complete") {
                                    print("Requesting data transfer")
                                    
                                    dataTransferRequest()
                                    
                                    // if the transfer request failed, then recall data transfer to try again
                                    if !prefs.bool(forKey: "Transfer complete") {
                                        print("Retrying data transfer")
                                        dataTransfer()
                                    } else {
                                        print("Data transferred successfully")
                                        task.setTaskCompleted(success: true)
                                        // make sure to cancel the background task when it's done being used
                                        backgroundTask?.cancel()
                                        
                                        // This is for signaling the view when the transfer is done to call this function that switches to the next view
                                        DispatchQueue.main.async {
                                            NotificationCenter.default.post(name: .transferComplete, object: nil)
                                        }
                                    }
                                    
                                    
                                    
                                } else {
                                    print("Data transferred successfully")
                                    task.setTaskCompleted(success: true)
                                    backgroundTask?.cancel()
                                    
                                    // This is for signaling the view when the transfer is done to call this function that switches to the next view
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .transferComplete, object: nil)
                                    }
                                }
                                
                            }
                        }
                        
                        func dataTransfer() {
                            retryCount += 1
                            print("Retrying data transfer (Attempt \(retryCount))")
                            scheduleNextRetry()
                            
                        }
                        
                        
                    }
                }
                
            }
            
        }// Geometry reader
        
    }
    
    func dataTransferRequest() {
        print("Data transfer request called")
        let transferRequest = UnsecureTransfer()
        let transferStatus = transferRequest.TransferRequest()
        
        return
    }
    
    
    func transferDone() {
        print("Transfer done called")
        transferComplete = true
        DispatchQueue.main.async {
            backgroundTask?.cancel()
        }
        
    }
    
    // Checks if notifications permissions have been given
    func checkForPermissions() {
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
    }
    
    
}

struct Finished: View {
    
    var body: some View {
        AfterPhotosReceived()
    }
    
}


#Preview {
    YesSharePhotosResponse()
}
