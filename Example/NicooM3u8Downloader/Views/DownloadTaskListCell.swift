//
//  DownloadTaskListCell.swift
//  NicooM3u8Downloader_Example
//
//  Created by pro5 on 2019/2/16.
//  Copyright © 2019年 CocoaPods. All rights reserved.
//

import UIKit

class DownloadTaskListCell: UITableViewCell {
    
    static let cellId = "DownloadTaskListCell"

    lazy var imagePic: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "videoPic15.jpg")
        return imageView
    }()
    var videoNameLable: UILabel = {
        let lable = UILabel()
        lable.text = "视频名称"
        lable.font = UIFont.systemFont(ofSize: 16)
        return lable
    }()
    var progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressViewStyle = .default
        progress.progressTintColor = UIColor.green
        progress.trackTintColor = UIColor.groupTableViewBackground
        progress.progress = 0.0
        return progress
    }()
    var percentageLable: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 14)
        lable.textColor = UIColor.darkGray
        return lable
    }()
    lazy var statuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("等待下载", for: .normal)
        button.setTitleColor(UIColor.darkText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(statuButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    var downLoadStatuButtonClick:((_ sender: UIButton) -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imagePic)
        contentView.addSubview(videoNameLable)
        contentView.addSubview(statuButton)
        contentView.addSubview(progressView)
        contentView.addSubview(percentageLable)
        layoutPageSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func statuButtonClick(_ sender: UIButton) {
        downLoadStatuButtonClick?(sender)
    }
}


// MARK: - Layout
private extension DownloadTaskListCell {
    
    func layoutPageSubviews() {
        layoutImageView()
        layoutNameLable()
        layoutStatuButton()
        layoutProgressView()
        layoutPercentageLable()
    }
    
    func layoutImageView() {
        imagePic.snp.makeConstraints { (make) in
            make.leading.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.width.equalTo(70)
        }
    }
    
    func layoutNameLable() {
        videoNameLable.snp.makeConstraints { (make) in
            make.leading.equalTo(imagePic.snp.trailing).offset(10)
            make.top.equalTo(imagePic.snp.top)
            make.height.equalTo(20)
        }
    }
    
    func layoutStatuButton() {
        statuButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(75)
            make.height.equalTo(40)
        }
    }
    
    func layoutProgressView() {
        progressView.snp.makeConstraints { (make) in
            make.leading.equalTo(videoNameLable)
            make.trailing.equalTo(statuButton.snp.leading).offset(-10)
            make.height.equalTo(2)
            make.centerY.equalToSuperview()
        }
    }
    func layoutPercentageLable() {
        percentageLable.snp.makeConstraints { (make) in
            make.leading.equalTo(progressView)
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.height.equalTo(18)
            make.trailing.equalTo(statuButton.snp.leading).offset(-10)
        }
    }
}
