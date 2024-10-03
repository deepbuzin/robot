//
//  CameraView.swift
//  Robot
//
//  Created by Andrey Buzin on 02.10.2024.
//

import SwiftUI

struct CameraView: View {
    @State private var cameraModel = CameraModel()
    
    
    var body: some View {
        GeometryReader { geometry in
            CameraPreview(cameraModel: $cameraModel, frame: geometry.frame(in: .global))
                .onAppear {
                    cameraModel.requestAccessAndSetup()
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    CameraView()
}
