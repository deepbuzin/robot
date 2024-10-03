//
//  FaceTrackingModel.swift
//  Robot
//
//  Created by Andrey Buzin on 02.10.2024.
//

import AVFoundation
import Vision
import SwiftUI
import UIKit

@Observable
class FaceTrackingModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let detectRequest = DetectFaceRectanglesRequest()
    var observations: [FaceObservation] = []
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task(priority: .background) {
            do {
                let observations = try await detectRequest.perform(on: sampleBuffer, orientation: UIDevice.current.orientation.toCGImagePropertyOrientation)
                
                await MainActor.run {
                    self.observations = observations
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
