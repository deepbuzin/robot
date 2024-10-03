//
//  FaceTrackingModel+.swift
//  Robot
//
//  Created by Andrey Buzin on 03.10.2024.
//

import Foundation

extension FaceTrackingModel {
    func getOffset(in frame: CGSize) -> CGSize {
        guard let face = observations.first else { return .zero }
        let bbox = face.boundingBox.toImageCoordinates(frame, origin: .upperLeft)
        
        let offset = CGSize(width: (bbox.origin.x + bbox.width / 2) - frame.width / 2, height: (bbox.origin.y + bbox.height / 2) - frame.height / 2)
        return offset
    }
}
