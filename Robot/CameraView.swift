//
//  CameraView.swift
//  Robot
//
//  Created by Andrey Buzin on 25.09.2024.
//

import SwiftUI
import AVFoundation


class CameraManager: ObservableObject {
    @Published var session: AVCaptureSession?
    @Published var isAuthorized: Bool = false
    
    func checkAuthorization() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        // Determine whether a person previously authorized camera access.
        isAuthorized = status == .authorized
        // If the system hasn't determined their authorization status,
        // explicitly prompt them for approval.
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
    }
    
    func setupCamera() {
        do {
            let session = AVCaptureSession()
            
            guard let device = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) else {
                print("Failed to get the front camera device")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            session.sessionPreset = .high
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
            
            self.session = session
            
        } catch {
            print("Failed to setup camera: \(error.localizedDescription)")
        }
        
    }
}


func setupCamera() throws -> AVCaptureSession {
    let captureSession = AVCaptureSession()
    let device = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
    let input = try AVCaptureDeviceInput(device: device!)
    
    captureSession.addInput(input)
    captureSession.sessionPreset = .high
    
    let output = AVCaptureVideoDataOutput()
    captureSession.addOutput(output)
    
    return captureSession
}


struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
        
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}


struct CameraView: View {
    @StateObject var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            if let session = cameraManager.session {
                CameraPreview(session: session)
            } else {
                Text("No camera for you").foregroundColor(.white)
            }
            
            VStack {
               if cameraManager.isAuthorized {
                   Text("Camera Feed").foregroundColor(.white)
               } else {
                   Text("Camera access not authorized").foregroundColor(.white)
               }
                           
            }
        }.onAppear {
            Task {
                await cameraManager.checkAuthorization()
                if cameraManager.isAuthorized {
                    cameraManager.setupCamera()
                }
            }
        }
    }

}

#Preview {
    CameraView()
}
