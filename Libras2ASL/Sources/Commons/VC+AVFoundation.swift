//
//  VC+AVFoundation.swift
//  Libras2ASL
//
//  Created by Gustavo Rigor on 03/10/22.
//

import UIKit
import AVFoundation
import Vision

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var fingerPoints: [CGPoint]
        
        var thumbTip: CGPoint?
        var thumbIp: CGPoint?
        var thumbMp: CGPoint?
        var thumbCmc: CGPoint?
        
        let indexTip: CGPoint?
        let indexDip: CGPoint?
        let indexPip: CGPoint?
        let indexMcp: CGPoint?
        
        var middleTip: CGPoint?
        var middleDip: CGPoint?
        var middlePip: CGPoint?
        var middleMcp: CGPoint?
        
        var ringTip: CGPoint?
        var ringDip: CGPoint?
        var ringPip: CGPoint?
        var ringMcp: CGPoint?
        
        var littleTip: CGPoint?
        var littleDip: CGPoint?
        var littlePip: CGPoint?
        var littleMcp: CGPoint?
        
        var wrist: CGPoint?

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                cameraView.showPoints([])
                return
            }
            
            // Get points for all fingers
            let handPoints = try observation.recognizedPoints(.all)
            
            for points in handPoints {
                
            }
            
            // Extract individual points from Point groups.
            guard let thumbTipPoint = handPoints[.thumbTip],
                  let thumbIpPoint = handPoints[.thumbIP],
                  let thumbMpPoint = handPoints[.thumbMP],
                  let thumbCmcPoint = handPoints[.thumbCMC],
                  
                  let indexTipPoint = handPoints[.indexTip],
                  let indexDipPoint = handPoints[.indexDIP],
                  let indexPipPoint = handPoints[.indexPIP],
                  let indexMcpPoint = handPoints[.indexMCP],
                  
                  let middleTipPoint = handPoints[.middleTip],
                  let middleDipPoint = handPoints[.middleDIP],
                  let middlePipPoint = handPoints[.middlePIP],
                  let middleMcpPoint = handPoints[.middleMCP],
                  
                  let ringTipPoint = handPoints[.ringTip],
                  let ringDipPoint = handPoints[.ringDIP],
                  let ringPipPoint = handPoints[.ringPIP],
                  let ringMcpPoint = handPoints[.ringMCP],
                  
                  let littleTipPoint = handPoints[.littleTip],
                  let littleDipPoint = handPoints[.littleDIP],
                  let littlePipPoint = handPoints[.littlePIP],
                  let littleMcpPoint = handPoints[.littleMCP],
                  
                  let wristPoint = handPoints[.wrist]
            else {
                cameraView.showPoints([])
                return
            }
            
            let confidenceThreshold: Float = 0.5
            guard   thumbTipPoint.confidence > confidenceThreshold &&
                        thumbIpPoint.confidence > confidenceThreshold &&
                        thumbMpPoint.confidence > confidenceThreshold &&
                        thumbCmcPoint.confidence > confidenceThreshold &&
                        
                        indexTipPoint.confidence > confidenceThreshold &&
                        indexDipPoint.confidence > confidenceThreshold &&
                        indexPipPoint.confidence > confidenceThreshold &&
                        indexMcpPoint.confidence > confidenceThreshold &&
                        
                        middleTipPoint.confidence > confidenceThreshold &&
                        middleDipPoint.confidence > confidenceThreshold &&
                        middlePipPoint.confidence > confidenceThreshold &&
                        middleMcpPoint.confidence > confidenceThreshold &&
                        
                        ringTipPoint.confidence > confidenceThreshold &&
                        ringDipPoint.confidence > confidenceThreshold &&
                        ringPipPoint.confidence > confidenceThreshold &&
                        ringMcpPoint.confidence > confidenceThreshold &&
                        
                        littleTipPoint.confidence > confidenceThreshold &&
                        littleDipPoint.confidence > confidenceThreshold &&
                        littlePipPoint.confidence > confidenceThreshold &&
                        littleMcpPoint.confidence > confidenceThreshold &&
                        
                        wristPoint.confidence > confidenceThreshold
            
            else {
                cameraView.showPoints([])
                return
            }
            
            // Convert points from Vision coordinates to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            thumbIp = CGPoint(x: thumbIpPoint.location.x, y: 1 - thumbIpPoint.location.y)
            thumbMp = CGPoint(x: thumbMpPoint.location.x, y: 1 - thumbMpPoint.location.y)
            thumbCmc = CGPoint(x: thumbCmcPoint.location.x, y: 1 - thumbCmcPoint.location.y)
            
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
            indexDip = CGPoint(x: indexDipPoint.location.x, y: 1 - indexDipPoint.location.y)
            indexPip = CGPoint(x: indexPipPoint.location.x, y: 1 - indexPipPoint.location.y)
            indexMcp = CGPoint(x: indexMcpPoint.location.x, y: 1 - indexMcpPoint.location.y)
            
            middleTip = CGPoint(x: middleTipPoint.location.x, y: 1 - middleTipPoint.location.y)
            middleDip = CGPoint(x: middleDipPoint.location.x, y: 1 - middleDipPoint.location.y)
            middlePip = CGPoint(x: middlePipPoint.location.x, y: 1 - middlePipPoint.location.y)
            middleMcp = CGPoint(x: middleMcpPoint.location.x, y: 1 - middleMcpPoint.location.y)
            
            ringTip = CGPoint(x: ringTipPoint.location.x, y: 1 - ringTipPoint.location.y)
            ringDip = CGPoint(x: ringDipPoint.location.x, y: 1 - ringDipPoint.location.y)
            ringPip = CGPoint(x: ringPipPoint.location.x, y: 1 - ringPipPoint.location.y)
            ringMcp = CGPoint(x: ringMcpPoint.location.x, y: 1 - ringMcpPoint.location.y)
            
            littleTip = CGPoint(x: littleTipPoint.location.x, y: 1 - littleTipPoint.location.y)
            littleDip = CGPoint(x: littleDipPoint.location.x, y: 1 - littleDipPoint.location.y)
            littlePip = CGPoint(x: littlePipPoint.location.x, y: 1 - littlePipPoint.location.y)
            littleMcp = CGPoint(x: littleMcpPoint.location.x, y: 1 - littleMcpPoint.location.y)
            
            wrist = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
            
            DispatchQueue.main.async {
                self.processPoints(
                    [
                        thumbTip,
                        thumbIp,
                        thumbMp,
                        thumbCmc,
                        
                        indexTip,
                        indexDip,
                        indexPip,
                        indexMcp,
                        
                        middleTip,
                        middleDip,
                        middlePip,
                        middleMcp,
                        
                        ringTip,
                        ringDip,
                        ringPip,
                        ringMcp,
                        
                        littleTip,
                        littleDip,
                        littlePip,
                        littleMcp,
                
                        wrist
                    ]
                )
            }
        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}
