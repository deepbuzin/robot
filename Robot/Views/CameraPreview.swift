//
//  CameraPreview.swift
//  Robot
//
//  Created by Andrey Buzin on 02.10.2024.
//

import SwiftUI
import AVFoundation
//import UIKit

struct CameraPreview: UIViewRepresentable {
    @Binding var cameraModel: CameraModel
    let frame: CGRect
    
    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: frame)
        cameraModel.preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
        cameraModel.preview.frame = frame
        cameraModel.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraModel.preview)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // handle rotation
        cameraModel.preview.frame = frame
        cameraModel.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
    }
    
}
