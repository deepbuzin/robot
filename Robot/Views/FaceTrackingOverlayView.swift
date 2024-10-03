//
//  FaceTrackingOverlayView.swift
//  Robot
//
//  Created by Andrey Buzin on 02.10.2024.
//

import SwiftUI
import Vision


struct FaceTrackingOverlayView: View {
    @Binding var observations: [FaceObservation]
    
    var body: some View {
        
        GeometryReader { geometry in
            ForEach(observations, id: \.self) { observation in
                Path { path in
                    let rect = observation.boundingBox.toImageCoordinates(geometry.size, origin: .upperLeft)
                    path.addRect(rect)
                }
                .stroke(.green, lineWidth: 3)
            }
        }
    }
}

#Preview {
//    FaceTrackingOverlayView()
}
