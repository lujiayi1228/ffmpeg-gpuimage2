//
//  RecordManage.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/24.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

class RecordManager: NSObject {
    
    //相机
    private lazy var camera: GPUImageVideoCamera = {
        let ca = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .back)!
        do {
            try ca.inputCamera.lockForConfiguration()
        }catch {
            //自动对焦
            if ca.inputCamera.isFocusModeSupported(.continuousAutoFocus) {
                ca.inputCamera.focusMode = .continuousAutoFocus
            }
            //自动曝光
            if (ca.inputCamera.isExposureModeSupported(.continuousAutoExposure)) {
                ca.inputCamera.exposureMode = .continuousAutoExposure
            }
            //自动白平衡
            if (ca.inputCamera.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance)) {
                ca.inputCamera.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            
            ca.inputCamera.unlockForConfiguration()
        }
        
        ca.outputImageOrientation = .portrait
        ca.addAudioInputsAndOutputs()
        ca.horizontallyMirrorRearFacingCamera = false
        ca.horizontallyMirrorFrontFacingCamera = true
        ca.addTarget((self.beautifyFilter as! GPUImageInput))
        self.beautifyFilter.addTarget(filterdVideoView)
        return ca
    }()
    
    //美颜滤镜
    private lazy var beautifyFilter: GPUImageOutput = {
        let f = LFGPUImageEmptyFilter()
        return f
    }()
    
    //预览
    lazy var filterdVideoView: GPUImageView = {
        let fview = GPUImageView(frame: screenFrame)
        return fview
    }()
    
    //当前滤镜(怀旧风格等)
    private var filter : GPUImageFilter?
    
    //剪裁滤镜(录制画面的篇幅)
    private var cropFilter : GPUImageCropFilter?
    
    //视频保存路径,合成视频后删除文件
    private let videoPath = documentPath! + "/RecordVideo"
    
    //video数组
    private var videos : [URL] = []
    
    //录制状态
    private var isRecording = false
    
    //存储
    private var movieWriter : GPUImageMovieWriter?
    
    override init() {
        super.init()
        setupRecorder()
    }
    
    private func setupRecorder() {
        filter = GPUImageFilter()
        cropFilter = GPUImageCropFilter()
        camera.startCapture()
        createVideoFolder()
    }
    
    private func createVideoFolder() {
        let fileManager = FileManager.default
        var isDir : ObjCBool = ObjCBool(false)
        let isExist = fileManager.fileExists(atPath: videoPath, isDirectory: &isDir)
        if !(isDir.boolValue && isExist) {
            do {
                try fileManager.createDirectory(atPath: videoPath, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("recordvideo文件夹创建失败")
            }
        }
    }
    
    //开始录制
    func startRecording() {
        let moviePath = URL(fileURLWithPath: videoPath + "/\(videos.count).mov")
        movieWriter = GPUImageMovieWriter.init(movieURL: moviePath, size: CGSize(width: 720, height: 1280))
        movieWriter?.encodingLiveVideo = true
        movieWriter?.shouldPassthroughAudio = true
        filter?.addTarget(movieWriter)
        camera.audioEncodingTarget = movieWriter
        movieWriter?.startRecording()
        isRecording = true
        videos.append(moviePath)
    }
    
    //停止录制
    func stopRecording() {
        camera.audioEncodingTarget = nil
        guard videos.count != 0 else { return }
        if isRecording {
            movieWriter?.finishRecording()
            filter?.removeTarget(movieWriter)
        }else {
            return
        }
        isRecording = false
        
    }
    
    //退出
    func cancel(finished:()->()) {
        if isRecording {
            movieWriter?.cancelRecording()
            filter?.removeTarget(movieWriter)
        }
        camera.stopCapture()
        camera.removeAllTargets()
        beautifyFilter.removeAllTargets()
        finished()
    }
    
    //美颜开关
    func changeBeautify(isOpen:Bool) {
        camera.removeAllTargets()
        beautifyFilter = isOpen ? GPUImageBeautifyFilter() : LFGPUImageEmptyFilter()
        camera.addTarget((beautifyFilter as! GPUImageInput))
        beautifyFilter.addTarget(filterdVideoView)
    }
    
    //镜头方向
    func changeCameraPosition() {
        camera.pauseCapture()
        camera.rotateCamera()
        camera.resumeCameraCapture()
    }
    
    //添加滤镜(不与美颜冲突)
    func changeFilter(newFilter :GPUImageFilter) {
        self.filter = newFilter
        changeAllFilter()
    }
    
    //画幅变更
    func changeVideoFrame(frame:CGRect) {
        self.cropFilter = GPUImageCropFilter(cropRegion: frame)
        changeAllFilter()
    }
    
    private func changeAllFilter() {
        camera.removeAllTargets()
        beautifyFilter.removeAllTargets()
        self.filter?.removeAllTargets()
        self.cropFilter?.removeAllTargets()
        camera.addTarget((beautifyFilter as! GPUImageInput))
        beautifyFilter.addTarget(self.cropFilter)
        self.cropFilter!.addTarget(self.filter)
        self.filter!.addTarget(filterdVideoView)
    }
}
