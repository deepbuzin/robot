//
//  FaceView.swift
//  Robot
//
//  Created by Andrey Buzin on 23.09.2024.
//

import SwiftUI
import Vision

struct RobotFaceView: View {
    @State private var cameraModel = CameraModel()
    @State private var faceTrackingModel = FaceTrackingModel()
    
    let queue = DispatchQueue(label: "video")
    
    var body: some View {
        VStack {
            EyesView(gaze: faceTrackingModel.getOffset(in: CGSize(width: 300, height: 300)))
        }
        .onAppear {
            cameraModel.requestAccessAndSetup()
            cameraModel.output.setSampleBufferDelegate(faceTrackingModel, queue: queue)
        }
    }
}

#Preview {
    RobotFaceView()
}
