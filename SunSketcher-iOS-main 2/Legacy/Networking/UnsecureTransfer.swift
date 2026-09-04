//
//  UnsecureTransfer.swift
//  iOS-Server
//
//  Created by Travis Peden on 3/1/24.
//

/*
 This file is for the data transfer between the client and the server. Here it requests the ID and receives an ID from the server.
 The ID is saved within the UserDefaults.
 */

import Foundation
import CryptoKit
import Network

struct UnsecureTransfer {
    var client: ClientConnection
    let prefs = UserDefaults.standard
    
    
    init() {
        client = ClientConnection(nwConnection: NWConnection(host: "161.6.109.198", port: 10000, using: .tcp))
    }
    
    func IDRequest() -> Bool {
        client.didStopCallback = didStopCallback(error:)
        client.start()
        sleep(1)
        
        print("Connection with server started successfully.")
        
        var clearToSend = ""
        client.receiveMessageString {
            message in
            if let message = message {
                clearToSend = message
            }
        }
        sleep(1)
        
        if (clearToSend == "true") {
            print("Sending server the necessary settings for ID the connection settings to the serverRequest.")
            
            //send the connection settings to the server
            client.send(data: Data("IDRequest\n".utf8))
            client.send(data: Data("uIOS\n".utf8))
            
            //send the passkey for authentication
            client.send(data: Data("SarahSketcher2024\n".utf8))
            sleep(1)
            
            print("Waiting for ID to be received.")
            //attempt to receive clientID
            var clientID = -1
            client.receiveMessageString {
                message in
                if let message = message {
                    clientID = Int(message) ?? -1
                }
            }
            sleep(1)
            
            if (clientID != -1) {
                //write client ID to prefs
                let prefs = UserDefaults.standard
                prefs.set(clientID, forKey: "ClientID")
                print("ClientID received successfully: \(clientID.description)")
                
                self.prefs.set(true, forKey: "ClientID obtained")
                client.stop()
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func TransferRequest() -> Bool {
            client.start()
            sleep(1)
            
            print("Connection with server started successfully.")
            
            var clearToSend = ""
            client.receiveMessageString {
                message in
                if let message = message {
                    clearToSend = message
                }
            }
            sleep(1)
            
            if (clearToSend == "true") {
                print("Sending server the necessary settings for IDRequest.")
                //send the connection settings to the server
                client.send(data: Data("TransferRequest\n".utf8))
                client.send(data: Data("uIOS\n".utf8))
                
                //send the passkey for authentication
                client.send(data: Data("SarahSketcher2024\n".utf8))
                sleep(1)
                
                print("Sending client ID: \(UserDefaults.standard.integer(forKey: "ClientID").description)")
                client.send(data: Data("\(UserDefaults.standard.integer(forKey: "ClientID"))\n".utf8))

                
                // Call the databse to retrieve the entries
                let metadataArray = MetadataDB.shared.retrieveImageMeta()
                
                // Retrieve the amount of entries to send to the server so it knows how much to expect
                let arrayCount = metadataArray.count
                client.send(data: Data("\(arrayCount)\n".utf8))

                //loop through database entries
                for metadata in metadataArray {
                    
                    let filepath = metadata.filepath
                    let filename = URL(string: filepath)!.lastPathComponent
                    let fileNameData = Data("\(filename)\n".utf8)
                    
                    var fileData: Data? = nil

                        do {
                            let fileURL = NSURL(fileURLWithPath: filepath)
                            print("Filepath to read from: \(fileURL.absoluteString)")
                            
                            fileData = try Data(referencing: NSData(contentsOf: fileURL as URL))
                            
                            print("fileData: \(fileData)")
                        } catch {
                            print("Error converting file to Data: \(error.localizedDescription)")
                        }
                    
                       
                    // For some reason the capture time isn't being returned correctly when retrieving it from the database so
                    // to ensure the correct capture time of the images are being sent to the server, I retrieve it from the filepath instead.
                    let unixTimeStamp1 = filepath.components(separatedBy: "_")
                    let unixTimeStamp2 = unixTimeStamp1[1].components(separatedBy: ".")
                    
                    // Convert numeric values to Data
                    let latitudeData = Data("\(metadata.latitude)\n".utf8)
                    let longitudeData = Data("\(metadata.longitude)\n".utf8)
                    let altitudeData = Data("\(metadata.altitude)\n".utf8)
                    let captureTimeData = Data("\(unixTimeStamp2[0])\n".utf8)
                    let apertureData = Data("\(metadata.aperture)\n".utf8)
                    let isoData = Data("\(metadata.iso)\n".utf8)
                    let whiteBalanceData = Data("\(metadata.whiteBalance)\n".utf8)
                    let focusDistanceData = Data("\(metadata.focalDistance)\n".utf8)
                    let exposureData = Data("\(metadata.exposureTime)\n".utf8)
                    
                    // Send the data to the server. It's in this order because this is the order the server expects the data.
                    client.send(data: fileNameData)
                    client.send(data: fileData?.base64EncodedData() ?? Data())
                    client.send(data: Data("\n".utf8))
                    client.send(data: latitudeData)
                    client.send(data: longitudeData)
                    client.send(data: altitudeData)
                    client.send(data: captureTimeData)
                    client.send(data: apertureData)
                    client.send(data: isoData)
                    client.send(data: whiteBalanceData)
                    client.send(data: focusDistanceData)
                    client.send(data: exposureData)
                    
                    
                }
                
                var canDisconnect = "no"
                client.receiveMessageString {
                    message in
                    if let message = message {
                        canDisconnect = message
                    }
                }
                
                while(canDisconnect == "no") {
                    print("Can't disconnect yet.")
                    sleep(2)
                }
                prefs.set(true, forKey: "Transfer complete")
            }
            
            client.stop()
            return true
        
    }
    
    func didStopCallback(error: Error?) {
        if error == nil {
            exit(EXIT_SUCCESS)
        } else {
            exit(EXIT_FAILURE)
        }
    }

    
}
