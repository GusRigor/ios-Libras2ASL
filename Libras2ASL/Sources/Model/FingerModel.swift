//
//  DataModel.swift
//  Libras2ASL
//
//  Created by Gustavo Rigor on 06/09/22.
//

import UIKit
import Vision

struct FingerModel {
    
    var fingerName: VNHumanHandPoseObservation.JointName
    var visionPoint: VNRecognizedPoint
      
    init(name: VNHumanHandPoseObservation.JointName, visionPoint: VNRecognizedPoint) {
        self.fingerName = name
        self.visionPoint = visionPoint
    }
    
}
