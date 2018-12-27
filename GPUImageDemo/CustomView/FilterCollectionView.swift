//
//  FilterCollectionView.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/25.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class FilterCollectionView: UICollectionView {
    
    private var datasource: [[String: String]] = {
        let arr = [["key":"YuanTu","title":"原图"],
                   ["key":"HuaiJiu","title":"怀旧"],
                   ["key":"DiPian","title":"底片"],
                   ["key":"HeiBai","title":"黑白"],
                   ["key":"FuDiao","title":"浮雕"],
                   ["key":"MengLong","title":"朦胧"],
                   ["key":"KaTong","title":"卡通"],
                   ["key":"TuQi","title":"凸起"],
                   ["key":"ShuiJin","title":"水晶"]]
        
        return arr
    }()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        (layout as! UICollectionViewFlowLayout).scrollDirection = .horizontal
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configView() {
        self.dataSource = self
        self.register(filterCell.self, forCellWithReuseIdentifier: "cell")
        self.backgroundColor = clearColor
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
}

extension FilterCollectionView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! filterCell
        cell.filterName = self.datasource[indexPath.row]
        return cell
    }
}
