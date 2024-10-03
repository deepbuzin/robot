//
//  EyesView.swift
//  Robot
//
//  Created by Andrey Buzin on 03.10.2024.
//

import SwiftUI

struct EyesView: View {
    @State private var blink: Bool = false
    var gaze: CGSize
    
    var body: some View {
        HStack(spacing: 40) {
            Capsule()
                .fill(Color.white)
                .frame(width: blink ? 50 : 50, height: blink ? 10 : 50)
                .offset(x: gaze.width, y: gaze.height)
                
            Capsule()
                .fill(Color.white)
                .frame(width: blink ? 50 : 50, height: blink ? 10 : 50)
                .offset(x: gaze.width, y: gaze.height)
        }
        .animation(.bouncy(extraBounce: 0.2), value: gaze)
        .onAppear {
            doBlinking()
        }
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
//    EyesView()
}
