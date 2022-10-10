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
    
    lazy var resetButton: UIButton = {
        let view = UIButton(type: .roundedRect)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.layer.cornerRadius = 20
        view.isHidden = true
        return view
    }()
    
    var cameraView: CameraView
    
    var handPosition: HandPositions
    
    let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    var cameraFeedSession: AVCaptureSession?
    var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    var imageEat: UIImage
    var imageHi: UIImage
    var imageNoon: UIImage
    
    var restingHand = true
    
    //MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        cameraView = CameraView()
        handPosition = .handResting
        imageEat = UIImage()
        imageHi = UIImage()
        imageNoon = UIImage()
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
        setupView()
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
        
        if (indexUp < 0 &&
            middleUp < 0 &&
            ringUp > 0 &&
            littleUp > 0) {
            
            let distanceFingers = hypotf(Float(indexTip.x - middleTip.x),Float(indexTip.y - middleTip.y))
            if distanceFingers < 20 {
                if handPosition == .handResting {
                    self.restingHand = false
                    descriptionLabel.text = "2 dedos levantados"
                    gifImage.isHidden = true
                    changeRestingHand()
                    handPosition = .midday
                    changeImageToNoon()
                }
                
                else if handPosition == .midday {
                    self.restingHand = false
                    descriptionLabel.text = "Meio dia - Noon"
                    gifImage.isHidden = false
                    print("Meio dia")
                    self.handPosition = .finalPosition
                }
            }
            
        }
        
        else if (indexUp > 0 &&
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
                } else if (handPosition == .littleUp) {
                    self.restingHand = false
                    descriptionLabel.text = "Oi - Hi"
                    gifImage.isHidden = false
                    print("Oi")
                    self.handPosition = .finalPosition
                }
            }
        }

        else if (indexUp < 0 &&
            middleUp < 0 &&
            ringUp < 0 &&
            littleUp < 0) {
            if self.restingHand {
                if handPosition == .handResting {
                    self.restingHand = false
                    descriptionLabel.text = "Mão levantada"
                    gifImage.isHidden = true
                    changeRestingHand()
                    handPosition = .firstHandUp
                } else if handPosition == .firstHandDown {
                    self.restingHand = false
                    descriptionLabel.text = "Comer - eat"
                    gifImage.isHidden = false
                    print("Comer")
                    handPosition = .finalPosition
                }
            }
        }

        else if(indexUp > 0 &&
                middleUp > 0 &&
                ringUp > 0 &&
                littleUp > 0) {
            if self.restingHand {
                if handPosition == .firstHandUp {
                    self.restingHand = false
                    descriptionLabel.text = "Mão abaixada"
                    gifImage.isHidden = true
                    changeImageToEat()
                    changeRestingHand()
                    handPosition = .firstHandDown
                }
            }

        }
        else if handPosition == .finalPosition {
            resetButton.isHidden = false
            print("aparece botão")
        }

        cameraView.showPoints(pointsConverted)
    }
    
    func resetWordForFinalPosition() {
        if handPosition == .finalPosition {
            self.restingHand = true
            descriptionLabel.text = "Faça uma palavra em Libras:"
            gifImage.isHidden = true
            print("Mão Fora")
            resetRestingHand()
        }
    }
    
    func changeRestingHand() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !self.restingHand {
                self.restingHand = true
            }
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
    
    func changeImageToNoon() {
        DispatchQueue.main.async {
            self.gifImage.image = self.imageNoon
        }
    }
    
    func resetRestingHand() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.handPosition = .handResting
            self.resetButton.isHidden = true
            print("Resetou as posições")
        }
    }
    
    @objc
    func didTapResetButton() {
        resetWordForFinalPosition()
    }
    
}
