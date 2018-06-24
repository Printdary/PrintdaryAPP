//
//  ImageUplader.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 15.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit

class ImageUploader: NSObject,StreamDelegate {
    
    var readStream  :Unmanaged<CFReadStream>?
    var writeStream :Unmanaged<CFWriteStream>?
    var inputStream : InputStream?
    var outputStream : OutputStream?
    let writeBackgroundQueue = DispatchQueue(label: "writheBackgroundQueue", qos: .background)
    let semaphore = DispatchSemaphore(value: 1)
   
    
    
    
    func connectSocket() {
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "52.175.233.168" as CFString, 44444, &self.readStream, &self.writeStream)
        self.inputStream = self.readStream!.takeRetainedValue()
        self.outputStream = self.writeStream!.takeRetainedValue()
        self.inputStream?.delegate = self
        self.outputStream?.delegate = self
        self.inputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        self.outputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        self.inputStream?.open()
        self.outputStream?.open()
        
        
        
        
    }
    
    func sendDate(){
        self.writeBackgroundQueue.async {
//            self.semaphore.wait()
//            var data = image?.cgImage?.dataProvider?.data! as Data?
//            data!.insert(UInt8(type), at: 0)
//            data!.insert(UInt8(1), at: 0)
//            data!.insert(UInt8(1), at: 0)
//            data!.insert(UInt8(1), at: 0)
//            
//            let bytesWritten = data?.withUnsafeBytes { self.outputStream?.write($0, maxLength: (data?.count)!) }
//            // print("bytesWritten = \(String(describing: bytesWritten))")
//            self.semaphore.signal()
        }
    }
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
        case .openCompleted:
            print("openCompleted")
            break
        case .hasBytesAvailable:
            print("hasBytesAvailable")
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            if ( aStream == inputStream){
                while (inputStream?.hasBytesAvailable)!{
                    
                    let numberOfBytesRead = inputStream?.read(buffer, maxLength: bufferSize)
                    if numberOfBytesRead! < 0 {
                        if let _ = inputStream?.streamError {
                            break
                        }
                    }
                    
                    
                    
                    let stringArray = String(bytesNoCopy: buffer,
                                             length: numberOfBytesRead!,
                                             encoding: .utf16,
                                             freeWhenDone: true)?.components(separatedBy: ":")
                    
                    print(stringArray)
                    
                }
            }
            
            break
        case .hasSpaceAvailable:
            break
        case .errorOccurred:
            print("NSStreamEventErrorOccurred")
           
            break
        case . endEncountered:
            print("NSStreamEventEndEncountered")
            
            break
        default:
            print("default")
        }
    }
    
}
