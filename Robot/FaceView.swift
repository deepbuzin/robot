//
//  FaceView.swift
//  Robot
//
//  Created by Andrey Buzin on 23.09.2024.
//

import SwiftUI

struct FaceView: View {
    
    @State private var blink: Bool = false
    @State private var gaze: CGSize = .zero
    
    var body: some View {
        HStack(spacing: 40) {
            eyeView(offset: gaze)
            eyeView(offset: gaze)
        }
        .onAppear {
            doBlinking()
        }
        .gesture(DragGesture().onChanged { value in
            gaze = value.translation
        }
            .onEnded { value in
                gaze = .zero
                
            }
        ).animation(.bouncy(extraBounce: 0.2), value: gaze)
    }
    
    func eyeView (offset: CGSize) -> some View {
        Capsule()
            .fill(Color.white)
            .frame(width: blink ? 50 : 50, height: blink ? 10 : 50)
            .offset(x: offset.width, y: offset.height)
//            .animation(.easeInOut(duration: 0.3), value: isBlinking)
    }
    
    func doBlinking() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                blink = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    blink = false
                }
            }
        }
    }
}

#Preview {
    FaceView()
}
