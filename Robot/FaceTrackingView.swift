//
//  FaceTrackingView.swift
//  Robot
//
//  Created by Andrey Buzin on 28.09.2024.
//

import SwiftUI
import Vision
import AVFoundation

class TrackingManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var session: AVCaptureSession?
    @Published var isAuthorized: Bool = false
    
    let detectRequest = DetectFaceRectanglesRequest()
    @State var detectionStatus: String = "nothing yet"
    @State var observations: [FaceObservation] = []
    @State var image: UIImage?
    
    func checkAuthorization() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        var isAuthorized = status == .authorized
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
        return isAuthorized
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
    
    @MainActor func updateObservations(_ newObservations: [FaceObservation]) {
        self.observations = newObservations
        self.detectionStatus = "detected \(newObservations.count) faces"
    }
    
    func performDetection(sampleBuffer: CMSampleBuffer) async {
        do {
            let response = try await detectRequest.perform(on: sampleBuffer)
            
            await MainActor.run {
                updateObservations(response)
                print(response)
            }
            
            
        } catch {
            detectionStatus = "caught error: \(error.localizedDescription)"
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task {
            await performDetection(sampleBuffer: sampleBuffer)
        }
    }
}

struct TrackingPreview: UIViewRepresentable {
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


struct FaceTrackingView: View {
    @StateObject var trackingManager = TrackingManager()
    
    var body: some View {
        ZStack {
            if let session = trackingManager.session {
                TrackingPreview(session: session)
            } else {
                Text("No camera for you").foregroundColor(.white)
            }
            
            VStack {
               if trackingManager.isAuthorized {
                   Text("Camera Feed").foregroundColor(.white)
               } else {
                   Text("Camera access not authorized").foregroundColor(.white)
               }
                           
            }
        }.onAppear {
            Task {
                let isAuthorized = await trackingManager.checkAuthorization()
                await MainActor.run {
                    trackingManager.isAuthorized = isAuthorized
                }
                
                if trackingManager.isAuthorized {
                    trackingManager.setupCamera()
                    
                    await MainActor.run {
                        if let session = trackingManager.session {
                            let output = AVCaptureVideoDataOutput()
                            if session.canAddOutput(output) {
                                session.addOutput(output)
                            }
                            
                            let queue = DispatchQueue(label: "videoQueue")
                            output.setSampleBufferDelegate(trackingManager, queue: queue)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    FaceTrackingView()
}
