//
//  RecordVC.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/24.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class RecordVC: UIViewController {

    //关闭按钮
    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 20, y: 40, width: 40, height: 40)
        btn.backgroundColor = clearColor
        btn.setTitle("×", for: .normal)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }()
    
    //录制按钮
    private lazy var recordBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: realValue_W(value: 160), height: realValue_W(value: 160))
        btn.centerX = self.view.centerX
        btn.bottom = screenHeight - realValue_H(value: 180)
        btn.layer.cornerRadius = btn.width/2
        btn.layer.borderWidth = 4
        btn.layer.borderColor = whiteColor.cgColor
        btn.layer.masksToBounds = true
        btn.backgroundColor = colorStr(color: "#FF4141")
        btn.addTarget(self, action: #selector(recordAction(sender:)), for: .touchUpInside)
        return btn
    }()
    
    //窗口变形按钮
    private lazy var windowTypeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: realValue_W(value: 28), height: realValue_W(value: 46))
        btn.centerY = self.recordBtn.centerY
        btn.centerX = self.recordBtn.left / 3
        btn.backgroundColor = clearColor
        btn.layer.borderWidth = 2
        btn.layer.borderColor = whiteColor.cgColor
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(changeRecordWindow(sender:)), for: .touchUpInside)
        return btn
    }()
    
    //滤镜按钮
    private lazy var filterBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: realValue_W(value: 46), height: realValue_W(value: 46))
        btn.centerY = self.windowTypeBtn.centerY
        btn.centerX = self.windowTypeBtn.centerX * 2
        btn.setTitle("滤", for: .normal)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.addTarget(self, action: #selector(filterAction(sender:)), for: .touchUpInside)
        return btn
    }()
    
    //镜头方向按钮
    private lazy var directionBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = self.filterBtn.frame
        btn.centerX = self.recordBtn.right + self.windowTypeBtn.centerX
        btn.centerY = self.recordBtn.centerY
        btn.setTitle("后", for: .normal)
        btn.setTitle("前", for: .selected)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.setTitleColor(whiteColor, for: .selected)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(directionAction(sender:)), for: .touchUpInside)
        return btn
    }()
    
    //美颜按钮
    private lazy var beautyBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = self.directionBtn.frame
        btn.centerX = self.directionBtn.centerX + self.windowTypeBtn.centerX
        btn.centerY = self.directionBtn.centerY
        btn.setTitle("美", for: .normal)
        btn.setTitle("丑", for: .selected)
        btn.isSelected = true
        btn.backgroundColor = clearColor
        btn.setTitleColor(whiteColor, for: .normal)
        btn.addTarget(self, action: #selector(beautyAction(sender:)), for: .touchUpInside)
        return btn
    }()
    
    //导入按钮
    private lazy var importBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: realValue_W(value: 80), height: realValue_W(value: 80))
        btn.left = self.closeBtn.left
        btn.bottom = screenHeight - 10
        btn.addTarget(self, action: #selector(importAction), for: .touchUpInside)
        btn.backgroundColor = clearColor
        btn.setTitle("导入", for: .normal)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        return btn
    }()
    
    //视频分段展示区
    private lazy var segCollectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: realValue_W(value: 80), height: realValue_W(value: 80))
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        layout.scrollDirection = .horizontal
        let col = UICollectionView(frame: CGRect(x: 0, y: 0, width: realValue_W(value: 350), height: realValue_W(value: 80)), collectionViewLayout: layout)
        col.backgroundColor = clearColor
        col.centerY = self.importBtn.centerY
        col.centerX = self.view.centerX
        col.delegate = self
        col.dataSource = self
        col.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        col.showsHorizontalScrollIndicator = false
        return col
    }()
    
    //分段设置按钮
    private lazy var segSetBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = self.importBtn.frame
        btn.right = screenWidth - self.importBtn.left
        btn.centerY = self.importBtn.centerY
        btn.setTitle("分段", for: .normal)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.addTarget(self, action: #selector(segSettingAction), for: .touchUpInside)
        return btn
    }()
    
    //滤镜列表
    private lazy var filterList: FilterCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 55, height: 55)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        let collection = FilterCollectionView(frame: CGRect(x: 8, y:self.recordBtn.top - 60, width: screenWidth - 16, height: 55), collectionViewLayout: layout)
        collection.delegate = self
        collection.isHidden = true
        return collection
    }()
    
    //录制者
    private lazy var recorder : RecordManager = {
        let re = RecordManager()
        return re
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    private func configView() {
        self.view.backgroundColor = UIColor.cyan
        self.navigationController?.navigationBar.isHidden = true
        self.view.addSubview(recorder.filterdVideoView)
        self.view.addSubview(self.closeBtn)
        self.view.addSubview(self.windowTypeBtn)
        self.view.addSubview(self.filterBtn)
        self.view.addSubview(self.recordBtn)
        self.view.addSubview(self.directionBtn)
        self.view.addSubview(self.beautyBtn)
        self.view.addSubview(self.importBtn)
        self.view.addSubview(self.segCollectionV)
        self.view.addSubview(self.segSetBtn)
        self.view.addSubview(self.filterList)
    }
    
}

extension RecordVC :UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filterList {
            let filter = MovieFilter.filter(tag: indexPath.row)
            recorder.changeFilter(newFilter: filter)
        }
    }
    
    //关闭
    @objc private func closeAction() {
        recorder.cancel { [weak self] in
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    //录制
    @objc private func recordAction(sender:UIButton) {
        !sender.isSelected ? recorder.startRecording() : recorder.stopRecording()
        sender.isSelected = !sender.isSelected
    }
    
    //变更录制画面frame
    @objc private func changeRecordWindow(sender:UIButton) {
        let frame = sender.isSelected ?
                    CGRect(x: 0, y: 44/screenHeight, width: 1, height: screenWidth/screenHeight) :
                    CGRect(x: 0, y: 0, width: 1, height: 1)
        recorder.changeVideoFrame(frame: frame)
        sender.isSelected = !sender.isSelected
    }
    
    //滤镜
    @objc private func filterAction(sender:UIButton) {
        filterList.isHidden = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    //镜头方向
    @objc private func directionAction(sender:UIButton) {
        recorder.changeCameraPosition()
        sender.isSelected = sender.isSelected
    }
    
    //美颜
    @objc private func beautyAction(sender:UIButton) {
        recorder.changeBeautify(isOpen: sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    
    //导入
    @objc private func importAction() {
        
    }
    
    //分段设置
    @objc private func segSettingAction() {
        
    }
    

}
