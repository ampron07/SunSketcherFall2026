//
//  Socket.swift
//  Sunsketcher
//
//  Created by Shikha Sawant on 2/7/24.
//

/*
 This file was not used for the SunSketcher app release in March 2024. This file can be used when trying to figure out a more secure
 way of transferring data to the server.
 */


import Foundation
import Security
 
 
 
class Socket: NSObject, StreamDelegate {
    var inputStream: InputStream!
    var outputStream: OutputStream!
 
    var isConnected: Bool {
        return inputStream.streamStatus == .open && outputStream.streamStatus == .open
    }
 
    func setupNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "161.6.109.198" as CFString, 10000, &readStream, &writeStream)
 
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
 
        inputStream.delegate = self
        outputStream.delegate = self
 
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
 
        inputStream.open()
        outputStream.open()
    }
 
 
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case .openCompleted:
            if aStream == inputStream {
                print("Input stream connected")
            } else if aStream == outputStream {
                print("Output stream connected")
            }
            case .errorOccurred:
            print("Error occurred")
            case .endEncountered:
            print("End encountered")
            case .hasBytesAvailable:
            print("Has bytes available")
            case .hasSpaceAvailable:
            print("Has space available")
            default:
            break
        }
    }
 
    //define parameters for key generation
    func generateRSAKeyPair(keySize: Int) throws ->(SecKey, SecKey){
        var publicKey, privateKey: SecKey?
 
        let parameters: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits as String: keySize,
        ]
        let status = SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
 
        guard status == errSecSuccess, let publicKey = publicKey, let privateKey = privateKey else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
 
        return (publicKey, privateKey)
    }
    func sendPublicKey(publicKey: SecKey) {
        // Convert public key to data
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) else {
            print("Error converting public key to data")
            return
        }

        // Get a pointer to the bytes of the public key data
        guard let ptr = CFDataGetBytePtr(publicKeyData) else {
            print("Error getting byte pointer")
            return
        }

        // Write data containing the public key to the output stream
        let bytesWritten = outputStream.write(ptr, maxLength: CFDataGetLength(publicKeyData))
        if bytesWritten < 0 {
            print("Error sending public key")
        } else {
            print("Public key sent successfully")
        }
    }


// Call this method after setting up the network communication to send the public key
    func sendPublicKey() {
        do {
            let keySize = 2048 // Update???
            let (publicKey, _) = try generateRSAKeyPair(keySize: keySize)
                sendPublicKey(publicKey: publicKey)
            } catch {
                print("Error generating or sending public key: \(error)")
            }
        }
    func receiveEncryptedAESKey() -> Data? {
        // Define a buffer to read data from the input stream
        var buffer = [UInt8](repeating: 0, count: 1024) // Adjust the buffer size as necessary
 
        // Read data from the input stream
        let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
 
        if bytesRead < 0 {
            print("Error reading from input stream")
            return nil
        }
 
        // Create a data object from the received bytes
        let receivedData = Data(bytes: buffer, count: bytesRead)
        return receivedData
    }
 
    func decryptAESKey(encryptedKeyData: Data, privateKey: SecKey) -> Data? {
        // Decrypt the received AES key using the private key
        var error: Unmanaged<CFError>?
        guard let decryptedKeyData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA256, encryptedKeyData as CFData, &error) as Data? else {
            print("Error decrypting AES key:", error!.takeRetainedValue() as Error)
            return nil
        }
        return decryptedKeyData
    }
 
// Call these methods after setting up the network communication to receive and decrypt the AES key
    func receiveAndDecryptAESKey(privateKey: SecKey) -> Data? {
        guard let encryptedAESKeyData = receiveEncryptedAESKey() else {
            return nil
        }
 
        print("Received encrypted AES key:")
            let encryptedAESKeyHex = encryptedAESKeyData.map { String(format: "%02x", $0) }.joined()
            print(encryptedAESKeyHex)

            let decryptedAESKeyData = decryptAESKey(encryptedKeyData: encryptedAESKeyData, privateKey: privateKey)
            return decryptedAESKeyData
    }
}

