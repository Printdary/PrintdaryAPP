//
//  ImageRecognitionManager.swift
//  ARKitExample
//
//  Created by Wang on 10/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import CoreML
import Vision

final class ImageRecognitionManager {
    
    static let shared = ImageRecognitionManager()
    
    // MARK: - Methods
    
    // Detect Image
    func detectScene(image: CIImage, completion: @escaping (_ result: String, _ error: Error?) -> ()) {
        
        var result = ""
        print("Detecting image...")
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Can't load Inception ML model")
        }
        
        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
            }
            
            // Update UI on main queue
            DispatchQueue.main.async {
                result = topResult.identifier
                completion(result, nil)
            }
        }
        
        // Run the Core ML model classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
                completion(error.localizedDescription, error)
            }
        }
    }
}
