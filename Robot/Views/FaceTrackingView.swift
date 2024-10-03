//
//  BetterFaceTrackingView.swift
//  Robot
//
//  Created by Andrey Buzin on 02.10.2024.
//

import SwiftUI

struct FaceTrackingView: View {
    @State private var cameraModel = CameraModel()
    @State private var faceTrackingModel = FaceTrackingModel()
    let queue = DispatchQueue(label: "video")
    
    var body: some View {
        GeometryReader { geometry in
            CameraPreview(cameraModel: $cameraModel, frame: geometry.frame(in: .global))
                .overlay {
                    FaceTrackingOverlayView(observations: $faceTrackingModel.observations)
                }
                .onAppear {
                    cameraModel.requestAccessAndSetup()
                    cameraModel.output.setSampleBufferDelegate(faceTrackingModel, queue: queue)
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FaceTrackingView()
}
