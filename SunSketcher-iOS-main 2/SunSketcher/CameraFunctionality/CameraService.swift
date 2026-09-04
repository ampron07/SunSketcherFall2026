//
//  CameraService.swift
//  Sunsketcher
//
//  Created by Tameka Ferguson on 10/9/23.
//  Edited by Emily Kedenburg on 4/23/26.
//

/*
 This file controls most of the camera function. This is where the photo capture timing is calculated, as well as setting camera settings, creating SunSketcher album, saving images to photos, directory and database.
 
 */

import Foundation
@preconcurrency import AVFoundation
@preconcurrency import Photos
import UIKit
import SwiftUI
import UserNotifications

@MainActor
class CameraService {
    
    init() {
        // print("[CameraRun] CameraService initialized")
    }
    
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    let prefs = UserDefaults.standard
    
    // For camera capture timers
    var firstTimer: Timer?
    var secondTimer: Timer?
    var thirdTimer: Timer?
    var midpointTimer: Timer?
    var fourthTimer: Timer?
    var fifthTimer: Timer?
    var sixthTimer: Timer?
    
    var photoCount: Int = 0
    
    // For location needed
    var locationManager = LocationManager.shared
    
    // For Photo Capture Timing
    var currentTime: Int = 0
    var randomizer: Int = 0
    var currentTimeMillis: Int = 0
    var startTime: Int = 0
    var endTime: Int = 0
    var midTime: Int = 0
    
    // For audio
    var audioPlayer: AVAudioPlayer?
    var notificationSent = false
   
    // Trigger sequence for Spain 26 eclipse
    let useSpainSchedule = true
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> ()) {
        self.delegate = delegate
        // Reset photo counter at the start of a camera run
        self.photoCount = 0
        // print("[CameraRun] Starting camera run. Photo count reset to 0")
        checkPermissions(completion: completion)
        
        // Schedule a timer to check and start capturing photos at the specified time
        scheduleTimerForPhotoCapture()
    }

    
    private func checkPermissions(completion: @escaping (Error?) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {return}
                DispatchQueue.main.async {
                    self?.setUpCamera(completion: completion)
                }
                // If you want the camera function to work on the background thread instead of main
                // This means that the user would not be able to see the view of CustomCameraView
                /*DispatchQueue.global(qos: .background).async {
                    self?.setUpCamera(completion: completion)
                }*/
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera(completion: completion)
        @unknown default:
            break
        }
    }
    
    private func setUpCamera(completion: @escaping (Error?) -> ()) {
        let session = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                DispatchQueue.global(qos: .background).async {
                    // print("[CameraRun] setUpCamera about to startRunning()")
                    session.startRunning()
                    // print("[CameraRun] setUpCamera did call startRunning()")
                }
                
                self.session = session
                // print("[CameraRun] setUpCamera configured session and previewLayer")
                
            } catch {
                completion(error)
            }
        }
        
    }
    /*
     The firstTimerDate, secondTimerDate, etc. are used to create a date variable for when the timers are suppose to start.
     The timeIntervals are the intervals between when the timer starts until the seconds before or after the startTime/endTime.
     Note we are using milliseconds for the startTime and endTime.
     
     How the app captures images is that it starts taking photos 20 seconds before second contact until 20 seconds after. A middle photo is then taken at totality. Then the photo captures start again 20 seconds before third contact until 20 seconds after.
     
     How the timer works:
     - Start timer to take 1 image per 2 seconds at (startTime - 20000) Note I have it at minus 22000 within the code because it waits two seconds before it takes that first image.
     - Switch to capture rate to 2 images per 1 second at (startTime - 10000)
     - Switch back to take 1 image per 2 seconds at (startTime + 10000)
     - Set timer to stop captures at (startTime + 20000)
     - Set timer to take 1 image at midpoint (midTime)
     - Start timer to take 1 image per 2 seconds at (endTime - 20000)
     - Switch to capture rate at 2 images per 1 second at (endTime - 10000)
     - Switch back to take 1 image per 2 seconds at (endTime + 10000)
     - Set timer to stop captures at (endTime + 20000)
     
     */
    
    
    private func scheduleTimerForPhotoCapture() {
        // print("[CameraRun] Entered scheduleTimerForPhotoCapture()")
        // Configure camera settings
        configureCameraSettings()
        
        // TODO: For actual release
        startTime = prefs.integer(forKey: "startTime")
        endTime = prefs.integer(forKey: "endTime")
        midTime = (endTime + startTime) / 2
        
        // print("[CameraRun] Scheduling capture timers. startTime(ms): \(startTime) endTime(ms): \(endTime) midTime(ms): \(midTime)")
        // print("Start Time: \(startTime), End Time: \(endTime)")
        // print("Schedule first timer.")
        
        let firstTimerDate = Date(timeIntervalSince1970: Double((startTime - 20000)/1000))
        print("First Timer Time: \(firstTimerDate)")
        
        let timeInterval = Date(timeIntervalSince1970: Double((startTime - 10000)/1000)).timeIntervalSince(firstTimerDate)
        print("First timer interval: \(timeInterval)")
        
        // Set a timer for the the date in which the timer is suppose to start and interval until the next one starts
        firstTimer = Timer(fire: firstTimerDate, interval: timeInterval, repeats: false) { [weak self] timer in
            // print("1")
            Task { @MainActor in
                self?.startSlowSequence1()
            }
        }
        
        // Schedule the timer on the main run loop
        RunLoop.main.add(firstTimer!, forMode: .common)
    }

    func startSlowSequence1() {
        let start = startTime
        // print("Starting slow sequence 1")

        secondTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else { return }
                
                // Capture photo
                self.capturePhoto()
                self.photoCount += 1
                // print("[CameraRun] Photo captured. total=\(self.photoCount)")
                
                // Check if it's time to stop the timer
                let stopTime = Date(timeIntervalSince1970: Double((start - 10000)/1000))
                // print("Stop time: \(stopTime)")
                if Date() >= stopTime {
                    print("Slow Sequence 1: \(self.photoCount)")
                    timer.invalidate()
                    self.scheduleSecondTimer()
                    // print("All photos taken.")
                }
            }
        }

    }
    
    
    func scheduleSecondTimer() {
        let start = startTime
        // print("Called second timer")
        let secondTimerDate = Date(timeIntervalSince1970: Double((start - 10000)/1000))
        // print("Second Timer Time: \(secondTimerDate)")
        
        let timeInterval = Date(timeIntervalSince1970: Double((start + 10000)/1000)).timeIntervalSince(secondTimerDate)
        
        secondTimer = Timer(fire: secondTimerDate, interval: timeInterval, repeats: false) { [weak self] timer in
            // print("2")
            Task { @MainActor in
                self?.startFastSequence1()
            }
        }
        
        RunLoop.main.add(secondTimer!, forMode: .common)
        
        
    }
    
    func startFastSequence1() {
        let start = startTime
        // print("Starting fast sequence 1")
        
        secondTimer = Timer.scheduledTimer(withTimeInterval: 0.19, repeats: true) { [weak self] timer in
            Task { @MainActor in
                    guard let self else { return }
                self.capturePhoto()
                self.photoCount += 1
                // print("[CameraRun] Photo captured. total=\(self.photoCount)")
                
                let stopTime = Date(timeIntervalSince1970: Double((start + 10000)/1000))
                // print("Stop time: \(stopTime)")
                if Date() >= stopTime {
                    print("Fast Sequence 1: \(self.photoCount)")
                    timer.invalidate()

                    if self.useSpainSchedule {
                        self.scheduleMidpointTimer()
                    } else {
                        self.scheduleThirdTimer()
                    }

                }
            }
        }
        
    }
    
    func scheduleThirdTimer() {
        let start = startTime
        // print("Called third timer")
        let thirdTimerDate = Date(timeIntervalSince1970: Double((start + 10000)/1000))
        // print("Third Timer Time: \(thirdTimerDate)")
        
        let timeInterval = Date(timeIntervalSince1970: Double((start + 20000)/1000)).timeIntervalSince(thirdTimerDate)
        
        thirdTimer = Timer(fire: thirdTimerDate, interval: timeInterval, repeats: false) { [weak self] timer in
            // print("3")
            Task { @MainActor in
                self?.startSlowSequence2()
            }
        }
        
        RunLoop.main.add(thirdTimer!, forMode: .common)
        
        
    }
    func startSlowSequence2() {
        let start = startTime
        // print("Starting slow sequence 2")
        thirdTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else { return }
                // Capture photo
                self.capturePhoto()
                self.photoCount += 1
                // print("[CameraRun] Photo captured. total=\(self.photoCount)")
                
                // Check if it's time to stop the timer
                let stopTime = Date(timeIntervalSince1970: Double((start + 20000)/1000))
                // print("Stop time: \(stopTime)")
                if Date() >= stopTime {
                    print("Slow Sequence 2: \(self.photoCount)")
                    timer.invalidate()
                    // print("Third timer done.")
                    self.scheduleMidpointTimer()
                }
            }
        }
        
    }
    
    func scheduleMidpointTimer() {
        // print("Called midpoint timer")
        // print("[CameraRun] Midpoint capture scheduled at midTime(ms): \(midTime)")
        
        // Configure midpoit exposure
        //configureExposure(midpoint: true)
        
        let midpointTimerDate = Date(timeIntervalSince1970: Double(midTime/1000))
        // print("Midpoint Timer Date: \(midpointTimerDate)")
        
        let timeInterval = 0.0
        
        midpointTimer = Timer(fire: midpointTimerDate, interval: timeInterval, repeats: false) {[weak self] timer in
            // print("mid")
            Task { @MainActor in
                self?.takeMidPic()
            }
        }
        
        RunLoop.main.add(midpointTimer!, forMode: .common)
    }
    
    func takeMidPic() {
        // print("Called takeMidPic")
        midpointTimer = Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { [weak self] timer in
            Task { @MainActor in
                guard let self else { return }
                self.capturePhoto()
                self.photoCount += 1
                
                print("Midpoint: \(self.photoCount)")
                
                timer.invalidate()
                
                if self.useSpainSchedule {
                    self.scheduleFifthTimer()
                } else {
                    self.scheduleFourthTimer()
                }

            }
        }
    }
    
    func scheduleFourthTimer() {
        // Reconfigure the exposure back to 1/8000
        configureExposure()
        
        let end = endTime
        // print("Called fourth timer")
        let fourthTimerDate = Date(timeIntervalSince1970: Double((end - 20000)/1000))
        // print("Fourth Timer Time: \(fourthTimerDate)")
        
        let timeInterval = Date(timeIntervalSince1970: Double((end - 10000)/1000)).timeIntervalSince(fourthTimerDate)
        
        fourthTimer = Timer(fire: fourthTimerDate, interval: timeInterval, repeats: false) { [weak self] timer in
            // print("4")
            Task { @MainActor in
                self?.startSlowSequence3()
            }
        }
        
        RunLoop.main.add(fourthTimer!, forMode: .common)
        
        
    }
    func startSlowSequence3() {
        let end = endTime
        // print("Starting slow sequence 3")
        fourthTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else { return }
                // Capture photo
                self.capturePhoto()
                self.photoCount += 1
                // print("[CameraRun] Photo captured. total=\(self.photoCount)")
                
                // Check if it's time to stop the timer
                let stopTime = Date(timeIntervalSince1970: Double((end - 10000)/1000))
                // print("Stop time: \(stopTime)")
                if Date() >= stopTime {
                    print("Slow Sequence 3: \(self.photoCount)")
                    timer.invalidate()
                    self.scheduleFifthTimer()
                }
            }
        }
        
    }
    
    func scheduleFifthTimer() {
        //ßconfigureExposure(midpoint: false)
        
        let end = endTime
        // print("Called fifth timer")
        let fifthTimerDate = Date(timeIntervalSince1970: Double((end - 10000)/1000))
        // print("Fifth Timer Time: \(fifthTimerDate)")
        
        let timeInterval = Date(timeIntervalSince1970: Double((end + 10000)/1000)).timeIntervalSince(fifthTimerDate)
        
        fifthTimer = Timer(fire: fifthTimerDate, interval: timeInterval, repeats: false) { [weak self] timer in
            // print("5")
            Task { @MainActor in
                self?.startFastSequence2()
            }
        }
        
        RunLoop.main.add(fifthTimer!, forMode: .common)
    }
    
    func startFastSequence2() {
        let end = endTime
        // print("Starting fast sequence 2")
        
        fifthTimer = Timer.scheduledTimer(withTimeInterval: 0.19, repeats: true) {[weak self] timer in
            Task { @MainActor in
                guard let self else { return }
                self.capturePhoto()
                self.photoCount += 1
                // print("[CameraRun] Photo captured. total=\(self.photoCount)")
                
                let stopTime = Date(timeIntervalSince1970: Double((end + 10000)/1000))
                // print("Stop time: \(stopTime)")
                if Date() >= stopTime {
                    print("Fast Sequence 2: \(self.photoCount)")
                    timer.invalidate()
                    self.scheduleSixthTimer()
                }
            }
        }
        
    }
    
    func scheduleSixthTimer() {
        let end = endTime
        // print("Called sixth timer")
        let sixthTimerDate = Date(timeIntervalSince1970: Double((end + 10000)/1000))
        // print("Sixth Timer Time: \(sixthTimerDate)")
        
        let timeInterval = Date(timeIntervalSince1970: Double((end + 20000)/1000)).timeIntervalSince(sixthTimerDate)
        
        sixthTimer = Timer(fire: sixthTimerDate, interval: timeInterval, repeats: false) { [weak self] timer in
            // print("6")
            Task { @MainActor in
                self?.startSlowSequence4()
            }
        }
        
        RunLoop.main.add(sixthTimer!, forMode: .common)
        
        
    }
    func startSlowSequence4() {
        let end = endTime
        // print("Starting slow sequence 4")
        fourthTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else { return }
                // Capture photo
                self.capturePhoto()
                self.photoCount += 1
                // print("[CameraRun] Photo captured. total=\(self.photoCount)")
                
                // Check if it's time to stop the timer
                let stopTime = Date(timeIntervalSince1970: Double((end + 20000)/1000))
                // print("Stop time: \(stopTime)")
                if Date() >= stopTime {
                    print("Slow Sequence 4: \(self.photoCount)")
                    timer.invalidate()
                    // print("All photos taken.")
                    print("Completed. Total photos captured=\(self.photoCount)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.exportMetadataToJSON()
                        self.exportMetadataToCSV()
                    }
                    self.flashTorchAndSound(seconds: 16)
                    self.prefs.set(true, forKey: "Photos complete")
                    
                }
            }
        }
        
    }
    
    
    // Setup the sound file to prepare to play once done
    // This is not currently being used
    func setupAudio() {
        // Replace your_sound_file with the actual audio file name you want to use
        // Make sure the audio file is within the project
        if let soundURL = Bundle.main.url(forResource: "your_sound_file", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                // print("Error initializing audio player: \(error.localizedDescription)")
            }
        }
    }
    
    
    // For the flash and sound to play after photos are taken
    func flashTorchAndSound(seconds: Int) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        // Check if the device has a torch
        guard device.hasTorch else {
            // print("Torch is not available on this device.")
            return
        }
        
        // Start flashing the torch
        var flashCounter = 0
        let flashTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            do {
                try device.lockForConfiguration()
                
                // Toggle the torch mode
                device.torchMode = (flashCounter % 2 == 0) ? .on : .off
                device.unlockForConfiguration()
                flashCounter += 1
                
                // Play the sound which is not currently used
                //self.audioPlayer?.play()
                
                // Stop flashing after the specified duration
                if flashCounter >= seconds {
                    timer.invalidate()
                    // print("Flash complete.")
                    // print("[CameraRun] Flash sequence complete. Final photo total=\(self.photoCount)")
                    return
                }
            } catch {
                // print("Error toggling torch during flash: \(error.localizedDescription)")
            }
        }
        
        // Schedule the timer on the main run loop
        RunLoop.main.add(flashTimer, forMode: .common)
        
    }
    
    func allPhotosCompleted() -> Bool {
        if(prefs.bool(forKey: "Photos complete")) {
            // print("[CameraRun] allPhotosCompleted() -> true. total=\(photoCount)")
            return true
        } else {
            // print("[CameraRun] allPhotosCompleted() -> false. total=\(photoCount)")
            return false
        }
    }

    
    //=========================testing============================
    func allMetas() {
        let metadataArray = MetadataDB.shared.retrieveImageMeta()

        for metadata in metadataArray {
            // print("ID: \(metadata.id), Latitude: \(metadata.latitude), Longitude: \(metadata.longitude), Altitude: \(metadata.altitude), Filepath: \(metadata.filepath), Capture Time: \(metadata.captureTime), ISO \(metadata.iso), Exposure time: \(metadata.exposureTime), White balance: \(metadata.whiteBalance), Focal distance: \(metadata.focalDistance), isCropped: \(metadata.isCropped)")
        }
    }
    //=========================testing============================
    
    
    func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        guard let cameraDevice = AVCaptureDevice.default(for: .video) else {
            // print("No video device found")
            return
        }
        
        let aperture = cameraDevice.lensAperture
        self.prefs.set(aperture, forKey: "Aperture")
        self.prefs.set(cameraDevice.iso, forKey: "ISO")
        self.prefs.set(cameraDevice.exposureDuration.seconds, forKey: "Exposure time")
        
        
        
        
        // Print current settings
        print("Current ISO: \(cameraDevice.iso)")
        // print("Current White Balance: \(cameraDevice.whiteBalanceMode)")
        // print("Current Exposure Time: \(cameraDevice.exposureDuration.seconds)")
        // print("Current Lens Position: \(cameraDevice.lensPosition)")
        // print("Current aperture: \(aperture)")
        
        
        output.capturePhoto(with: settings, delegate: delegate!)
    }
    
    // For camera settings
    // Setting and getting the camera settings are not accurate and will need to be fixed for future use
    // What it currently does is it is setting the camera setting with the values we give but we are not completely sure
    // that it is actually using those exact settings. So it is just saving to the database what we
    func configureCameraSettings() {
        
        guard let cameraDevice = AVCaptureDevice.default(for: .video) else {
            // print("No video device found")
            return
        }
        
        do {
            try cameraDevice.lockForConfiguration()
            
            // Print current settings
            print("Current ISO: \(cameraDevice.iso)")
            // print("Current White Balance: \(cameraDevice.whiteBalanceMode)")
            // print("Current Exposure Time: \(cameraDevice.exposureDuration.seconds)")
            // print("Current Lens Position: \(cameraDevice.lensPosition)")
            
            // Replace original ISO setting block with clamping logic
            let minISO = cameraDevice.activeFormat.minISO
            let maxISO = cameraDevice.activeFormat.maxISO
            let requestedISO: Float = 63
            let clampedISO = max(minISO, min(requestedISO, maxISO))
            if requestedISO != clampedISO {
                print("Requested ISO \(requestedISO) is not supported. Clamped to \(clampedISO) (range: \(minISO)-\(maxISO))")
            }
            cameraDevice.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: clampedISO, completionHandler: nil)
            self.prefs.set(clampedISO, forKey: "ISO")
            
            // Set the white balance
            if cameraDevice.isWhiteBalanceModeSupported(.locked) {
                let tempAndTint = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: 6600, tint: 0)
                let whiteBalanceGains = cameraDevice.deviceWhiteBalanceGains(for: tempAndTint)
                cameraDevice.setWhiteBalanceModeLocked(with: whiteBalanceGains, completionHandler: nil)
                
                self.prefs.set("6600K", forKey: "White balance")
            } else {
                // print("Custom white balance is not supported by the camera")
            }
            
            // Set exposure time
            let desiredExposureTime = CMTimeMake(value: 1, timescale: 8000)
            
            // Replace original exposure setting block with clamping logic for ISO
            if cameraDevice.isExposureModeSupported(.custom) {
                let requestedISO = prefs.float(forKey: "ISO")
                let clampedISO = max(minISO, min(requestedISO, maxISO))
                if requestedISO != clampedISO {
                    print("Requested ISO \(requestedISO) is not supported. Clamped to \(clampedISO) (range: \(minISO)-\(maxISO))")
                }
                cameraDevice.setExposureModeCustom(duration: desiredExposureTime, iso: clampedISO, completionHandler: nil)
                self.prefs.set(cameraDevice.exposureDuration.seconds, forKey: "Exposure time")
            } else {
                print("Custom exposure is not supported by the camera")
            }
            
            // Set focal distance
            // Some images were not focused correctly for the April 8th, eclipse so this would need fixing for future use.
            if cameraDevice.isFocusModeSupported(.autoFocus) {
                cameraDevice.focusMode = .autoFocus
                cameraDevice.setFocusModeLocked(lensPosition: 1.0, completionHandler: nil)
                self.prefs.set(cameraDevice.lensPosition, forKey: "Focal distance")
            } else {
                // print("Setting focus to infinity is not supported by the camera")
            }
            
            // Print current settings
            print("Set ISO: \(cameraDevice.iso)")
            // print("Set White Balance: \(cameraDevice.whiteBalanceMode)")
            // print("Set Exposure Time: \(cameraDevice.exposureDuration.seconds)")
            // print("Set Lens Position: \(cameraDevice.lensPosition)")
            
            cameraDevice.unlockForConfiguration()
        } catch {
            // print("Error configuring camera settings: \(error.localizedDescription)")
        }
        
    }
    
    func getSetCameraSettings() {
        guard let cameraDevice = AVCaptureDevice.default(for: .video) else {
            // print("No video device found")
            return
        }
        
        do {
            try cameraDevice.lockForConfiguration()
            
            self.prefs.set(cameraDevice.iso, forKey: "ISO")
            self.prefs.set(cameraDevice.exposureDuration.seconds, forKey: "Exposure time")
            self.prefs.set(cameraDevice.lensPosition, forKey: "Focal distance")
            
            // Print current settings
            print("Set ISO: \(cameraDevice.iso)")
            // print("Set Exposure Time: \(cameraDevice.exposureDuration.seconds)")
            // print("Set Lens Position: \(cameraDevice.lensPosition)")
            
            cameraDevice.unlockForConfiguration()
        } catch {
            // print("Error configuring camera settings: \(error.localizedDescription)")
        }
    }
    
    func configureExposure(midpoint: Bool = false) {
        guard let cameraDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        do {
            try cameraDevice.lockForConfiguration()

            let desiredExposureTime: CMTime

            if midpoint {
                desiredExposureTime = CMTimeMake(value: 1, timescale: 200)
            } else {
                desiredExposureTime = CMTimeMake(value: 1, timescale: 8000)
            }

            // Replace original block with clamping ISO logic
            if cameraDevice.isExposureModeSupported(.custom) {
                let minISO = cameraDevice.activeFormat.minISO
                let maxISO = cameraDevice.activeFormat.maxISO
                let requestedISO = prefs.float(forKey: "ISO")
                let clampedISO = max(minISO, min(requestedISO, maxISO))
                if requestedISO != clampedISO {
                    print("Requested ISO \(requestedISO) is not supported. Clamped to \(clampedISO) (range: \(minISO)-\(maxISO))")
                }
                cameraDevice.setExposureModeCustom(
                    duration: desiredExposureTime,
                    iso: clampedISO,
                    completionHandler: nil
                )

                if midpoint {
                    self.prefs.set(
                        cameraDevice.exposureDuration.seconds,
                        forKey: "Exposure time midpoint"
                    )
                } else {
                    self.prefs.set(
                        cameraDevice.exposureDuration.seconds,
                        forKey: "Exposure time"
                    )
                }
            } else {
                // print("Custom exposure is not supported by the camera")
            }

            cameraDevice.unlockForConfiguration()
        } catch {
            // print("Error configuring camera settings: \(error.localizedDescription)")
        }
    }
    
    // For creating an album folder within the phone's photo library
    func createSunSketcherAlbumIfNeeded(completion: @escaping (PHAssetCollection?) -> Void) {
        // Check if the "SunSketcher" album exists, and if not, create it.
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "SunSketcher")
        
        if let existingAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject {
            // The album already exists.
            completion(existingAlbum)
        } else {
            // Create a new album with the name "SunSketcher."
            PHPhotoLibrary.shared().performChanges {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "SunSketcher")
            } completionHandler: { success, error in
                if success {
                    // Get the newly created album and return it.
                    if let newAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject {
                        completion(newAlbum)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // For saving the images to the phone's photo library within the SunSketcher album
    func savePhotoToLibrary(_ photo: AVCapturePhoto) {
        createSunSketcherAlbumIfNeeded { album in
            if let album = album {
                if let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) {
                    // Save the image with a custom file name to the document directory
                    
                    PHPhotoLibrary.shared().performChanges {
                        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        
                        request.creationDate = Date()
                        if let currentLocation = self.locationManager.location {
                            request.location = currentLocation
                        } else {
                            // print("Warning: Location not available, using nil")
                        }

                        // Add the photo to the "SunSketcher" album.
                        if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                            albumChangeRequest.addAssets([request.placeholderForCreatedAsset!] as NSFastEnumeration)
                        }
                    } completionHandler: { success, error in
                        if success {
                            //print("Photo saved to the 'SunSketcher' album")
                        } else if let error = error {
                            // print("Error saving photo to the library: \(error.localizedDescription)")
                        }
                    }
                } else {
                    // print("Error: Unable to create UIImage from photo data")
                }
            } else {
                // print("Error creating 'SunSketcher' album")
            }
        }
    }


    
    // Add a method to save a UIImage to the document directory
    func saveImageToDocumentDirectory(_ image: UIImage) {
        // Specify the directory where images will be saved
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageSaveDirectory = documentsDirectory.appendingPathComponent("SunSketcher")
        
        let prefs = UserDefaults.standard
        
        // Create the directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: imageSaveDirectory, withIntermediateDirectories: true, attributes: nil)
            prefs.set(imageSaveDirectory, forKey: "imageFolderDirectory")
            
        } catch {
            // print("Error creating directory: \(error.localizedDescription)")
            return
        }
        //print("Image Directory: \(imageSaveDirectory)")
        
        
        // Generate a unique filename based on unix timestamp
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let fileName = "IMAGE_" + "\(timestamp)"
        
        
        let imageURL = imageSaveDirectory.appendingPathComponent("\(fileName).jpg")
        
        //let imageURL = imageURLFilename.appendingPathComponent(".jpg")
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            
            do {
                try imageData.write(to: imageURL)
                // print("[CameraRun] Saved image to disk: \(imageURL.lastPathComponent) total=\(self.photoCount)")
                
                let lat = prefs.float(forKey: "lat")
                let lon = prefs.float(forKey: "lon")
                let alt = prefs.float(forKey: "alt")
                
                let aperture = prefs.double(forKey: "Aperture")
                let iso = prefs.float(forKey: "ISO")
                
                var exposureTime: Float = 0.0
                if photoCount == 51 {
                    exposureTime = prefs.float(forKey: "Exposure time")
                } else{
                    exposureTime = prefs.float(forKey: "Exposure time")
                }
                // let whiteBalance = prefs.string(forKey: "White balance")
                let focalDistance = prefs.float(forKey: "Focal distance")
                
                /*print("\(Float(lat))")
                 print("\(Float(lon))")
                 print("\(Float(alt))")*/
                
                
                //print("Filepath: \(imageURL.relativePath)")
                let imageUrlString = "\(imageURL.relativePath)"
                let unixTimeStamp1 = imageUrlString.components(separatedBy: "_")
                let unixTimeStamp2 = unixTimeStamp1[1].components(separatedBy: ".")
                
                // Add the metadata to the database
                MetadataDB.shared.addImageMeta(latitude: Double(lat), longitude: Double(lon), altitude: Double(alt), filepath: imageUrlString, captureTime: Int64(unixTimeStamp2[0])!, aperture: aperture, iso: iso, exposureTime: exposureTime, whiteBalance: 0, focalDistance: focalDistance, isCropped: 0)
                
                // Check time accuracy
                // Record the current date and time
                /*let creationDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let formattedCreationDate = dateFormatter.string(from: creationDate)*/
                //print("Creation Date: \(formattedCreationDate)")
                
                if photoCount == 51{
                    return
                }
                
            } catch {
                // print("Error saving image to file: \(error.localizedDescription)")
            }
        }
    }
        
    func exportMetadataToJSON() {
        let metadataArray = MetadataDB.shared.retrieveImageMeta()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("SunSketcher/metadata.json")
        
        // Convert to dictionary format
        let jsonArray: [[String: Any]] = metadataArray.map { meta in
            return [
                "id": meta.id,
                "latitude": meta.latitude,
                "longitude": meta.longitude,
                "altitude": meta.altitude,
                "filepath": meta.filepath,
                "captureTime": meta.captureTime,
                "aperture": meta.aperture,
                "iso": meta.iso,
                "exposureTime": meta.exposureTime,
                "whiteBalance": meta.whiteBalance,
                "focalDistance": meta.focalDistance,
                "isCropped": meta.isCropped
            ]
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try jsonData.write(to: fileURL)
            
            // print("[CameraRun] Metadata exported to \(fileURL.path)")
        } catch {
            // print("Error exporting metadata: \(error.localizedDescription)")
        }
    }
    
    func exportMetadataToCSV() {
        let metadataArray = MetadataDB.shared.retrieveImageMeta()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("SunSketcher/metadata.csv")

        // CSV Header
        let headers = [
            "id",
            "latitude",
            "longitude",
            "altitude",
            "filepath",
            "captureTime",
            "aperture",
            "iso",
            "exposureTime",
            "whiteBalance",
            "focalDistance",
            "isCropped"
        ]

        // Helper to escape CSV fields
        func csvEscape(_ value: String) -> String {
            var v = value
            if v.contains("\"") { v = v.replacingOccurrences(of: "\"", with: "\"\"") }
            if v.contains(",") || v.contains("\n") || v.contains("\r") || v.contains("\"") { v = "\"" + v + "\"" }
            return v
        }

        var csv = headers.joined(separator: ",") + "\n"

        for meta in metadataArray {
            let row: [String] = [
                String(meta.id),
                String(meta.latitude),
                String(meta.longitude),
                String(meta.altitude),
                csvEscape(meta.filepath),
                String(meta.captureTime),
                String(meta.aperture),
                String(meta.iso),
                String(meta.exposureTime),
                String(meta.whiteBalance),
                String(meta.focalDistance),
                String(meta.isCropped)
            ]
            csv += row.joined(separator: ",") + "\n"
        }

        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try csv.data(using: .utf8)?.write(to: fileURL)
            // print("[CameraRun] Metadata exported to CSV at \(fileURL.path)")
        } catch {
            // print("Error exporting metadata CSV: \(error.localizedDescription)")
        }
    }

}

