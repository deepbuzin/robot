//
//  KeanuDetectionView.swift
//  Robot
//
//  Created by Andrey Buzin on 28.09.2024.
//

import SwiftUI
import Vision
import AVFoundation

struct KeanuDetectionView: View {
    let detectRequest = DetectFaceRectanglesRequest()
    @State var detectionStatus: String = "nothing yet"
    @State var observations: [FaceObservation] = []
    @State var image: UIImage?
    
    
    func doDetection() async {
        guard let uiImage = UIImage(named: "keanu") else {
            detectionStatus = "ui image broke"
            return
        }
        
        self.image = uiImage
        
        do {
            let cgImage = uiImage.cgImage!
            let response = try await detectRequest.perform(on: cgImage)
            
            detectionStatus = "detected \(response.count) faces"
            observations = response
            
            print(response)
            
        } catch {
            detectionStatus = "caught error: \(error.localizedDescription)"
        }
    }
    
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        GeometryReader { geometry in
                            ForEach(observations, id: \.self) { observation in
                                Path { path in
                                    let rect = observation.boundingBox.verticallyFlipped().toImageCoordinates(geometry.size)
                                    path.addRect(rect)
                                }
                                .stroke(Color.green, lineWidth: 2)
                            }
                        }
                    )
            }
            
        }.onAppear {
            Task {
                await doDetection()
            }
        }
    }
}

#Preview {
    KeanuDetectionView()
}
