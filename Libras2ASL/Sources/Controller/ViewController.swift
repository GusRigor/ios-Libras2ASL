//
//  ViewController.swift
//  Libras2ASL
//
//  Created by Gustavo Rigor on 05/09/22.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    //MARK: - Properties
    lazy var descriptionLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        return view
    }()
    
    lazy var gifImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = true
        view.layer.cornerRadius = 20
        view.isHidden = true
        return view
    }()
    
    var cameraView: CameraView
    
    var handPosition: HandPositions
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    var imageEat: UIImage
    var imageHi: UIImage
    
    var restingHand = true
    
    //MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        cameraView = CameraView()
        handPosition = .handResting
        imageEat = UIImage()
        imageHi = UIImage()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        
        addCameraView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Libras2ASL"
        
        let gifHiURL : String = "https://pa1.narvii.com/6427/90f2abb40e1757de174ffffe9bc5afb8e6845c60_hq.gif"
        let gifEatURL : String = "https://www.lifeprint.com/asl101/gifs/e/eat.gif"
        
        if let image = UIImage.gifImageWithURL(gifEatURL) {
            imageEat = image
        }
        
        if let image = UIImage.gifImageWithURL(gifHiURL) {
            imageHi = image
        }
        
        addDescriptionView()
        addImageView()
    }
    
    func addImageView() {
//        let gifURL : String = "https://www.lifeprint.com/asl101/gifs/e/eat.gif"
//        let gif = UIImage.gifImageWithURL(gifURL)
//
//        gifImage.image = gif
        gifImage.backgroundColor =  .white
        gifImage.layer.cornerRadius = 10
        gifImage.layer.masksToBounds = true
        
        gifImage.frame = CGRect(x: 100.0, y: 120.0, width: 200, height: 200.0)
        
        view.addSubview(gifImage)
        
        addImageViewConstraints()
    }
    
    func addImageViewConstraints() {
        gifImage.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 10).isActive = true
        gifImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        gifImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
    }
    
    func addDescriptionView() {
        descriptionLabel.text = "Faça uma palavra em Libras:"
        descriptionLabel.textAlignment = .center
        descriptionLabel.backgroundColor =  .white
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 20.0)
        descriptionLabel.layer.cornerRadius = 10
        descriptionLabel.layer.masksToBounds = true
        
        view.addSubview(descriptionLabel)
        
        addDescriptionViewConstraints()
    }
    
    func addDescriptionViewConstraints() {
        descriptionLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func addCameraView() {
        
        view.addSubview(cameraView)
        
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cameraView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 350).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 350).isActive = true
    }
    
    //MARK: - Configurations

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func setupAVSession() throws {
        // Select a front facing camera, make an input.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    func processPoints(_ points: [CGPoint?]) {
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        var pointsConverted: [CGPoint] = []
        for point in points {
            pointsConverted.append(previewLayer.layerPointConverted(fromCaptureDevicePoint: point!))
        }
        
        let thumbTip = pointsConverted[0]
        let thumbIp = pointsConverted[1]
        let thumbMp = pointsConverted[2]
        let thumbCmc = pointsConverted[3]
        
        let indexTip = pointsConverted[4]
        let indexDip = pointsConverted[5]
        let indexPip = pointsConverted[6]
        let indexMcp = pointsConverted[7]

        let middleTip = pointsConverted[8]
        let middleDip = pointsConverted[9]
        let middlePip = pointsConverted[10]
        let middleMcp = pointsConverted[11]

        let ringTip = pointsConverted[12]
        let ringDip = pointsConverted[13]
        let ringPip = pointsConverted[14]
        let ringMcp = pointsConverted[15]

        let littleTip = pointsConverted[16]
        let littleDip = pointsConverted[17]
        let littlePip = pointsConverted[18]
        let littleMcp = pointsConverted[19]
        
        let wrist = pointsConverted[pointsConverted.count - 1]
    

        let indexUp = indexTip.y - indexMcp.y
        let middleUp = middleTip.y - middleMcp.y
        let ringUp = ringTip.y - ringMcp.y
        let littleUp = littleTip.y - littleMcp.y
        
        if (indexUp > 0 &&
            middleUp > 0 &&
            ringUp > 0 &&
            littleUp < 0) {
            if self.restingHand {
                if handPosition == .handResting {
                    self.restingHand = false
                    descriptionLabel.text = "Dedinho levantado"
                    gifImage.isHidden = true
                    changeRestingHand()
                    handPosition = .littleUp
                    changeImageToHi()
                } else if handPosition == .littleUp {
                    self.restingHand = false
                    descriptionLabel.text = "Oi - Hi"
                    gifImage.isHidden = false
                    print("Oi")
                }
            }
        }
//
//        else if (indexUp < 0 &&
//            middleUp < 0 &&
//            ringUp < 0 &&
//            littleUp < 0) {
//            if self.restingHand {
//                if handPosition == .handResting {
//                    self.restingHand = false
//                    descriptionLabel.text = "Mão levantada"
//                    gifImage.isHidden = true
//                    changeRestingHand()
//                    handPosition = .firstHandUp
//                } else if handPosition == .firstHandDown {
//                    self.restingHand = false
//                    descriptionLabel.text = "Comer - eat"
//                    gifImage.isHidden = false
//                    print("Comer")
//                    handPosition = .secondHandUp
//                }
//            }
//        }
//
//        else if(indexUp > 0 &&
//                middleUp > 0 &&
//                ringUp > 0 &&
//                littleUp > 0) {
//            if self.restingHand {
//                if handPosition == .firstHandUp {
//                    self.restingHand = false
//                    descriptionLabel.text = "Mão abaixada"
//                    gifImage.isHidden = true
//                    changeImageToEat()
//                    changeRestingHand()
//                    handPosition = .firstHandDown
//                }
//            }
//
//        }
        else {
            self.restingHand = true
            descriptionLabel.text = "Faça uma palavra em Libras:"
            gifImage.isHidden = true
            print("Mão Fora")
            resetRestingHand()
        }

        cameraView.showPoints(pointsConverted)
    }
    
    func changeRestingHand() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.restingHand = true
        }
    }
    
    func changeImageToHi() {
        DispatchQueue.main.async {
            self.gifImage.image = self.imageHi
        }
    }
    
    func changeImageToEat() {
        DispatchQueue.main.async {
            self.gifImage.image = self.imageEat
        }
    }
    
    func resetRestingHand() {
        if restingHand {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.handPosition = .handResting
                
            }
        }
    }
    
}

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
            
            let confidenceThreshold: Float = 0.3
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
