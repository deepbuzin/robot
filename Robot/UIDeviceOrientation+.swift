//
//  UIDeviceOrientation+.swift
//  Robot
//
//  Created by Andrey Buzin on 02.10.2024.
//

import UIKit

extension UIDeviceOrientation {
    var videoRotationAngle: CGFloat {
        switch self {
        case .landscapeRight:
            0
        case .portrait:
            90
        case .landscapeLeft:
            180
        case .portraitUpsideDown:
            270
        default:
            90
        }
    }
    
    var toCGImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .landscapeRight:
                .upMirrored
        case .portrait:
                .leftMirrored
        case .landscapeLeft:
                .downMirrored
        case .portraitUpsideDown:
                .rightMirrored
        default:
                .leftMirrored
        }
    }
}
