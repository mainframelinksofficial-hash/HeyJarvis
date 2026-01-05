//
//  MetaWorkflowController.swift
//  HeyJarvisApp
//
//  Simulates Meta glasses workflows using iOS APIs
//

import Foundation
import AVFoundation
import Photos
import UIKit

class MetaWorkflowController: NSObject {
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var audioRecorder: AVAudioRecorder?
    private var isRecording = false
    private var recordingURL: URL?
    
    private var photoCaptureCompletion: ((Result<Void, Error>) -> Void)?
    
    override init() {
        super.init()
    }
    
    func capturePhoto() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.setupCaptureSession { result in
                    switch result {
                    case .success:
                        self.takePhoto { photoResult in
                            switch photoResult {
                            case .success:
                                continuation.resume()
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private func setupCaptureSession(completion: @escaping (Result<Void, Error>) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            initializeCaptureSession(completion: completion)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.initializeCaptureSession(completion: completion)
                    }
                } else {
                    completion(.failure(NSError(domain: "MetaWorkflow", code: 1, userInfo: [NSLocalizedDescriptionKey: "Camera access denied"])))
                }
            }
        default:
            completion(.failure(NSError(domain: "MetaWorkflow", code: 1, userInfo: [NSLocalizedDescriptionKey: "Camera access denied"])))
        }
    }
    
    private func initializeCaptureSession(completion: @escaping (Result<Void, Error>) -> Void) {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            completion(.failure(NSError(domain: "MetaWorkflow", code: 2, userInfo: [NSLocalizedDescriptionKey: "Camera not available"])))
            return
        }
        
        if captureSession?.canAddInput(input) == true {
            captureSession?.addInput(input)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, captureSession?.canAddOutput(photoOutput) == true {
            captureSession?.addOutput(photoOutput)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(.success(()))
            }
        }
    }
    
    private func takePhoto(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let photoOutput = photoOutput else {
            completion(.failure(NSError(domain: "MetaWorkflow", code: 3, userInfo: [NSLocalizedDescriptionKey: "Photo output not configured"])))
            return
        }
        
        photoCaptureCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func showLastVideo() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            
            switch status {
            case .authorized, .limited:
                self.fetchAndPlayLastVideo { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                    if newStatus == .authorized || newStatus == .limited {
                        self?.fetchAndPlayLastVideo { result in
                            switch result {
                            case .success:
                                continuation.resume()
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                    } else {
                        continuation.resume(throwing: NSError(domain: "MetaWorkflow", code: 4, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]))
                    }
                }
            default:
                continuation.resume(throwing: NSError(domain: "MetaWorkflow", code: 4, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]))
            }
        }
    }
    
    private func fetchAndPlayLastVideo(completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        
        guard let videoAsset = fetchResult.firstObject else {
            completion(.failure(NSError(domain: "MetaWorkflow", code: 5, userInfo: [NSLocalizedDescriptionKey: "No videos found"])))
            return
        }
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        
        PHImageManager.default().requestPlayerItem(forVideo: videoAsset, options: options) { playerItem, info in
            guard let playerItem = playerItem else {
                completion(.failure(NSError(domain: "MetaWorkflow", code: 6, userInfo: [NSLocalizedDescriptionKey: "Unable to load video"])))
                return
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .playVideo, object: playerItem)
                completion(.success(()))
            }
        }
    }
    
    func recordNote() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                if self.isRecording {
                    self.stopRecording { result in
                        switch result {
                        case .success:
                            continuation.resume()
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                } else {
                    self.startRecording { result in
                        switch result {
                        case .success:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                self.stopRecording { stopResult in
                                    switch stopResult {
                                    case .success:
                                        continuation.resume()
                                    case .failure(let error):
                                        continuation.resume(throwing: error)
                                    }
                                }
                            }
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
        }
    }
    
    private func startRecording(completion: @escaping (Result<Void, Error>) -> Void) {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            completion(.failure(error))
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "JarvisNote_\(dateFormatter.string(from: Date())).m4a"
        recordingURL = documentsPath.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            guard let url = recordingURL else {
                completion(.failure(NSError(domain: "MetaWorkflow", code: 9, userInfo: [NSLocalizedDescriptionKey: "Invalid recording URL"])))
                return
            }
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            isRecording = true
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func stopRecording(completion: @escaping (Result<Void, Error>) -> Void) {
        audioRecorder?.stop()
        isRecording = false
        audioRecorder = nil
        
        if let url = recordingURL, FileManager.default.fileExists(atPath: url.path) {
            completion(.success(()))
        } else {
            completion(.failure(NSError(domain: "MetaWorkflow", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to save recording"])))
        }
    }
    
    func cleanup() {
        captureSession?.stopRunning()
        captureSession = nil
        photoOutput = nil
        audioRecorder?.stop()
        audioRecorder = nil
    }
}

extension MetaWorkflowController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        captureSession?.stopRunning()
        
        if let error = error {
            photoCaptureCompletion?(.failure(error))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCaptureCompletion?(.failure(NSError(domain: "MetaWorkflow", code: 8, userInfo: [NSLocalizedDescriptionKey: "Failed to process photo"])))
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        if let error = error {
            photoCaptureCompletion?(.failure(error))
        } else {
            photoCaptureCompletion?(.success(()))
        }
        photoCaptureCompletion = nil
    }
}

extension Notification.Name {
    static let playVideo = Notification.Name("playVideo")
}
