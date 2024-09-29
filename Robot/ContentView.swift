//
//  ContentView.swift
//  Robot
//
//  Created by Andrey Buzin on 23.09.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
            
//            FaceView()
//            Text("Hello, world!")
//            CameraView()
//            let uiImage = UIImage(named: "keanu")!
//            KeanuDetectionView()
            FaceTrackingView()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
