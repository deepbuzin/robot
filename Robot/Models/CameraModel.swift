//
//  CameraModel.swift
//  Robot
//
//  Created by Andrey Buzin on 02.10.2024.
//

import Foundation
import AVFoundation
import UIKit

@Observable
class CameraModel {
    var session = AVCaptureSession()
    var preview = AVCaptureVideoPreviewLayer()
    var output = AVCaptureVideoDataOutput()
    
    func requestAccessAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { didAllowAccess in
                self.setup()
            }
        case .authorized:
            setup()
        default:
            print("other status")
        }
    }
    
    func setup() {
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        do {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            guard session.canAddInput(input) else { return }
            session.addInput(input)
            
            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            
            session.commitConfiguration()
            
            Task(priority: .background) {
                session.startRunning()
                
                // We need to do that on the main thread, but immediately after startRunning
                await MainActor.run {
                    self.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
