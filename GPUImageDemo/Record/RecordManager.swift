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
    
    private lazy var beautifyFilter: GPUImageOutput = {
        let f = LFGPUImageEmptyFilter()
        return f
    }()
    
    lazy var filterdVideoView: GPUImageView = {
        let fview = GPUImageView(frame: screenFrame)
        return fview
    }()
    
    private var firstRun = true
    
    private var paused = true
    
    private var isFront = false
    
    private var filter : GPUImageFilter?
    
    private var cropFilter : GPUImageCropFilter?
    
    override init() {
        super.init()
        setupRecorder()
    }
    
    private func setupRecorder() {
        filter = GPUImageFilter()
        cropFilter = GPUImageCropFilter()
        camera.startCapture()
    }
    
    //开始录制
    func startRecording() {
        
    }
    
    //停止录制
    func stopRecording() {
        
    }
    
    //退出
    func cancel(finished:()->()) {
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
        beautifyFilter.addTarget(self.filter)
        self.filter!.addTarget(self.cropFilter)
        self.cropFilter!.addTarget(filterdVideoView)
    }
}
