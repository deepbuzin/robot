//
//  FaceTrackingView.swift
//  Robot
//
//  Created by Andrey Buzin on 28.09.2024.
//

import SwiftUI
import Vision
import AVFoundation

@Observable class TrackingManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureSession?
    var isAuthorized: Bool = false
    
    let detectRequest = DetectFaceRectanglesRequest()
    
    var detectionStatus: String = "nothing yet"
    var observations: [FaceObservation] = []
    var image: UIImage?
    
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
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
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
            let response = try await detectRequest.perform(on: sampleBuffer, orientation: .left)
            
            await MainActor.run {
                updateObservations(response)
//                print(UIDevice.current.orientation.rawValue)
//                print(response)
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

struct FaceOverlayView: View {
    var observations: [FaceObservation]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(observations, id: \.self) { observation in
                Path { path in
                    let rect = observation.boundingBox.toImageCoordinates(geometry.size, origin: .lowerLeft)
                    path.addRect(rect)
                }
                .stroke(.green, lineWidth: 2)
            }
        }
//        .onChange(of: observations) { _, _ in
//            print("observations changed")
//        }
    }
}

struct TrackingPreview: UIViewRepresentable {
    let session: AVCaptureSession
        
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
//        previewLayer.connection?.videoRotationAngle = .zero
        
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
//        context.coordinator
    }
    
//    func makeCoordinator() -> () {
//        return Coordinator()
//    }
//    
//    class Coordinator {
//        var previewLayer: AVCaptureVideoPreviewLayer
//    }
}


struct FaceTrackingView: View {
    @State var trackingManager = TrackingManager()
    
    var body: some View {
        ZStack {
            if let session = trackingManager.session {
                TrackingPreview(session: session)
                    .overlay {
                        FaceOverlayView(observations: trackingManager.observations)
                    }
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
        }.task {
            await setupCamera()
        }
    }
    
    func setupCamera() async {
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
//                    output.connection(with: .video)?.videoRotationAngle = .zero
                }
            }
        }
    }
}

#Preview {
    FaceTrackingView()
}
