//
//  ClientConnection.swift
//  iOS-Server
//
//  Created by Travis Peden & Yegor Lushpin on 2/25/24.
//

/*
 This file is for forming the connection between the client and the server.
 */

import Foundation
import Network
import Combine

@available(macOS 10.14, *)
class ClientConnection: ObservableObject {
    
    let nwConnection: NWConnection
    let queue = DispatchQueue(label: "Client connection Q")
    let objectWillChange = PassthroughSubject<Void, Never>()
    let prefs = UserDefaults.standard
    
    
    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
    }

    var didStopCallback: ((Error?) -> Void)? = nil
    
    func start() {
        print("connection will start")
        nwConnection.stateUpdateHandler = stateDidChange(to:)
        nwConnection.start(queue: queue)
    }
    
    private func stateDidChange(to state: NWConnection.State) {
        objectWillChange.send()
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            print("Client connection ready")
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }
    
    
    func setupReceive() {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                let message = String(data: data, encoding: .utf8)
                print("connection did receive, data: \(data as NSData) string: \(message ?? "-")")
                print("Split message: \(message?.components(separatedBy: "\n") ?? ["Failed to split message"])")
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }
    
    var previouslyObtainedMessages = ""
    //keep receiving characters until a newline ("\n") character is received
    func receiveLine(str: inout String){
        var message = ""
        var messageIsFinished = false

        while(!messageIsFinished){
            //print("Message has not finished being received.")
            nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { (data, _, isComplete, error) in
                if let data = data, !data.isEmpty {
                    let incoming = String(data: data, encoding: .utf8)
                    //print("connection did receive, data: \(data as NSData) string: \(incoming ?? "error")")
                    /*let incomingArr = incoming?.components(separatedBy: "\n")
                        message.append(incomingArr?[0] ?? "")
                        if(incomingArr?.count ?? 2 > 1) {
                        messageIsFinished = true
                    }*/
                    var incomingMessage: String
                    
                    //sometimes the incoming message contains contents of previous messages as well, so we make sure to cut out anything already received
                    if(incoming!.contains(self.previouslyObtainedMessages)) {
                        print("New message includes previously obtained messages.")
                        let incomingMessageArr = incoming?.components(separatedBy: self.previouslyObtainedMessages)
                        if(incomingMessageArr!.count > 1) {
                            incomingMessage = incomingMessageArr![1]
                        } else {
                            incomingMessage = incomingMessageArr![0]
                        }
                    } else {
                        incomingMessage = incoming!
                    }
                    
                    //get everything up to the end of the incoming line
                    let incomingLine = incomingMessage.components(separatedBy: "\n")
                    message.append(incomingLine[0])
                            
                    //if a newline character was present (meaning, the end of the line was reached), stop reading from the incoming data buffer and return
                    if(incomingLine.count > 1) {
                        if(incomingLine[incomingLine.count - 1].elementsEqual("")) {
                            print("Incoming line ended.")
                            messageIsFinished = true
                                    
                            if(message.contains(self.previouslyObtainedMessages)) {
                                print("New message contains previous messages")
                                message = message.components(separatedBy: self.previouslyObtainedMessages)[1]
                            }
                            
                            return
                        }
                    }
                }
            }
        }
        //wait for the nsConnection to receive data
        sleep(1)
        
        //put the received data string into the pointer passed in
        print("Received message: \(message)")
        previouslyObtainedMessages.append(message)
        str = message
        return
    }

    
    func receiveMessageString(completion: @escaping (String?) -> Void) {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                let incoming = String(data: data, encoding: .utf8)
                var incomingMessage: String
                
                //sometimes the incoming message contains contents of previous messages as well, so we make sure to cut out anything already received
                if((incoming?.contains(self.previouslyObtainedMessages)) != nil) {
                    print("New message includes previously obtained messages.")
                    let incomingMessageArr = incoming?.components(separatedBy: self.previouslyObtainedMessages)
                    if(incomingMessageArr!.count > 1) {
                        incomingMessage = incomingMessageArr![1]
                    } else {
                        incomingMessage = incomingMessageArr![0]
                    }
                } else {
                    incomingMessage = incoming ?? ""
                }
                
                //get everything up to the end of the incoming line
                let incomingLine = incomingMessage.components(separatedBy: "\n")
                var message = incomingLine[0]
                        
                //if a newline character was present (meaning, the end of the line was reached), stop reading from the incoming data buffer and return
                if(incomingLine.count > 1) {
                    if(incomingLine[incomingLine.count - 1].elementsEqual("")) {
                                
                        if(message.contains(self.previouslyObtainedMessages)) {
                            message = message.components(separatedBy: self.previouslyObtainedMessages)[1]
                        }
                    }
                }
                
                completion(message)
            } else {
                completion(nil)
            }
            
            if let error = error {
                print("Error receiving message: \(error)")
            }
        }
     }
    
    /*func receiveMessageData(privateKey: SecKey, client: Client, completion: @escaping (Data?) -> Void) {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                var incomingData: Data
                print("Incoming data: \(data as NSData)")
                // Sometimes the incoming message contains contents of previous messages as well, so we make sure to cut out anything already received
                if let incoming = String(data: data, encoding: .utf8),
                   incoming.contains(self.previouslyObtainedMessages) {
                    print("New message includes previously obtained messages.")
                    let incomingMessageArr = incoming.components(separatedBy: self.previouslyObtainedMessages)
                    if incomingMessageArr.count > 1 {
                        let incomingMessage = incomingMessageArr[1]
                        incomingData = Data(incomingMessage.utf8)
                    } else {
                        let incomingMessage = incomingMessageArr[0]
                        incomingData = Data(incomingMessage.utf8)
                    }
                } else {
                    incomingData = data
                }
                
                let incomingTest = String(data: incomingData, encoding: .utf8)
                print("Incoming test string: \(incomingTest)")
                
                // Get everything up to the end of the incoming line
                if let incoming = String(data: incomingData, encoding: .utf8),
                   let incomingLine = incoming.components(separatedBy: "\n").first {
                    let message = Data(incomingLine.utf8)
                    print(message)
                    
                    let decrypted = client.decryptDataWithPrivateKey(dataToDecrypt: message, privateKey: privateKey)
                    
                    let aesKey = client.createSecKeyFromAESKeyData(aesKeyData: decrypted!)
                    print("AES Key: \(aesKey)")
                    
                    
                    completion(message)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
            
            if let error = error {
                print("Error receiving message: \(error)")
            }
        }
    }*/
    
    func testReceive(completion: @escaping (Data?) -> Void) {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { (data, _, isComplete, error) in
            if let message = data, !message.isEmpty {
                print("Incoming data: \(message as NSData)")
                completion(message)
            } else {
                completion(nil)
            }
        }
    }


    
    func receiveAESKey() -> String? {
        print("Waiting to receive a message from server...")
        
        var message: String = "-1"
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            /*if let data = data, !data.isEmpty {*/
            message = String(data: data!, encoding: .utf8)!
            //}
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
        sleep(1)
        
        return message
    }
    
    func setupReceiveTrue() -> Bool {
        var setupSuccessful = false
        
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                let message = String(data: data, encoding: .utf8)
                print("connection did receive, data: \(data as NSData) string: \(message ?? "-")")
            }
            if isComplete {
                self.connectionDidEnd()
                setupSuccessful = true // Set setupSuccessful to true when the setup completes
            } else if let error = error {
                self.connectionDidFail(error: error)
                setupSuccessful = false // Set setupSuccessful to false if there's an error
            } else {
                self.setupReceive()
                // Consider whether setupSuccessful should be set here if the setup is ongoing
            }
        }
        
        return setupSuccessful
    }
    
    func send(data: Data) {
        nwConnection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            print("connection did send, data: \(data as NSData); \(String(describing: String(data: data, encoding: .utf8)))")
        }))
    }
    
    func stop() {
        print("connection will stop")
        stop(error: nil)
    }
    
    private func connectionDidFail(error: Error) {
        objectWillChange.send()
        print("connection did fail, error: \(error)")
        self.stop(error: error)
    }
    
    private func connectionDidEnd() {
        objectWillChange.send()
        print("connection did end")
        self.stop(error: nil)
    }
    
    func receiveClientID(completion: @escaping (String?) -> Void) {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { (data, _, _, error) in
            if let error = error {
                print("Error receiving client ID: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("No client ID received")
                completion(nil)
                return
            }
            
            if let clientID = String(data: data, encoding: .utf8) {
                UserDefaults.standard.set(clientID, forKey: "clientID")
                print("Client ID saved: \(clientID)")
                completion(clientID)
            } else {
                print("Error decoding client ID data to string")
                completion(nil)
            }
        }
    }

    
    private func stop(error: Error?) {
        print("e")
        objectWillChange.send()
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        prefs.set(false, forKey: "Socket open")
        print("end")
    }
    
    

}
