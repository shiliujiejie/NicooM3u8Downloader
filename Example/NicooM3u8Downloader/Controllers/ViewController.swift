//
//  ViewController.swift
//  NicooM3u8Downloader
//
//  Created by yangxina on 01/21/2019.
//  Copyright (c) 2019 yangxina. All rights reserved.
//

import UIKit
import NicooM3u8Downloader

class ViewController: UIViewController {
    
    private lazy var downLoadBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x:30, y: 150, width: self.view.bounds.width - 60, height: 45)
        button.setTitle("download Double Parse m3u8", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(downLoad), for: .touchUpInside)
        return button
    }()
    
    private lazy var downLoadBtn1: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x:30, y: 200, width: self.view.bounds.width - 60, height: 45)
        button.setTitle("download Once Parse m3u8", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(downLoad1), for: .touchUpInside)
        return button
    }()
    private lazy var downLoadBtn2: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x:30, y: 250, width: self.view.bounds.width - 60, height: 45)
        button.setTitle("download Double With Key Parse m3u8", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(downLoad2), for: .touchUpInside)
        return button
    }()
    
    private lazy var playVideo: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x:30, y: 310, width: self.view.bounds.width - 60, height: 45)
        button.setTitle("play local tsList A", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(playLocalVideo), for: .touchUpInside)
        return button
    }()
    
    private lazy var playVideo1: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x:30, y:360, width: self.view.bounds.width - 60, height: 45)
        button.setTitle("play local tsList B", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(playLocalVideo1), for: .touchUpInside)
        return button
    }()
    
    private lazy var playVideo2: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x:30, y: 410, width: self.view.bounds.width - 60, height: 45)
        button.setTitle("play local tsList C", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(playLocalVideo2), for: .touchUpInside)
        return button
    }()
    private lazy var rightBarButton: UIBarButtonItem = {
        let barItem = UIBarButtonItem(title: "列表下载", style: .plain, target: self, action: #selector(goListDownLoad(_:)))
        barItem.tintColor = UIColor.darkText
        return barItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.navigationItem.rightBarButtonItem = rightBarButton
        view.addSubview(downLoadBtn)
        view.addSubview(downLoadBtn1)
        view.addSubview(downLoadBtn2)
        view.addSubview(playVideo)
        view.addSubview(playVideo1)
        view.addSubview(playVideo2)
    }

    @objc func goListDownLoad(_ sender: UIButton) {
        let taskVC = TaskListController()
        taskVC.title = "download Tasks"
        navigationController?.pushViewController(taskVC, animated: true)
    }
 
}

// MARK: - Privite User - Actions
extension ViewController {
    
    ///需要二次解析 .m3u8文件，再做拼接，在解析（递归）（非加密）
    // http://youku.com-www-163.com/20180506/576_bf997390/index.m3u8
    @objc func downLoad() {
        let url = "http://youku.com-www-163.com/20180506/576_bf997390/index.m3u8"
        let yagor = NicooYagor()
        yagor.directoryName = "keNan"
        yagor.m3u8URL = url
        yagor.delegate = self
        yagor.parse()
    }
    
    ///一次解析 .m3u8文件（非加密）
    //http://flv.bn.netease.com/videolib3/1707/03/bGYNX4211/SD/movie_index.m3u8
    //https://www3.yuboyun.com/hls/2018/11/25/SmRqndpr/playlist.m3u8
    @objc func downLoad1() {
        let url = "http://flv.bn.netease.com/videolib3/1707/03/bGYNX4211/SD/movie_index.m3u8"
        let yagor = NicooYagor()
        yagor.directoryName = "zhuBaJie"
        yagor.m3u8URL = url
        yagor.delegate = self
        yagor.parse()
    }
    
    ///需要二次解析 .m3u8文件，再做拼接，在解析（递归) ,最后下载密钥，将密钥写入本地，创建本地M3U8时，将本地密钥文件路径写入本地M3u8文件
    // 二次解析，带密钥
    // https://me.guiji365.com/20180616/LQfzeEFU/index.m3u8
    // 二次解析带密钥， 密钥中带IV
    ///http://192.168.137.145:50004/storage/v_m3u8/e7adf3d34b1e8a22a08657655212a038/index.m3u8
    @objc func downLoad2() {
        let url = "http://yun.kubo-zy-youku.com/20181112/BULbB7PC/index.m3u8"
        let yagor = NicooYagor()
        yagor.directoryName = "DLDL"
        yagor.m3u8URL = url
        yagor.delegate = self
        yagor.parse()
    }
    
    @objc func playLocalVideo() {
        let localPlayVC = DownLoadedVideoPlayerVC()
        localPlayVC.videoName = "keNan"
        navigationController?.pushViewController(localPlayVC, animated: true)
    }
    
    @objc func playLocalVideo1() {
        let localPlayVC = DownLoadedVideoPlayerVC()
        localPlayVC.videoName = "zhuBaJie"
        navigationController?.pushViewController(localPlayVC, animated: true)
    }
    
    @objc func playLocalVideo2() {
        let localPlayVC = DownLoadedVideoPlayerVC()
        localPlayVC.videoName = "DLDL"
        navigationController?.pushViewController(localPlayVC, animated: true)
    }
}
// MARK: - YagorDelegate
extension ViewController: YagorDelegate {
    
    func videoDownloadSucceeded(by yagor: NicooYagor) {
        let filePath = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile)
        print("downLoadFilePath = \(filePath). videoFileName = \(yagor.directoryName)")
        DispatchQueue.main.async {
            if yagor.directoryName == "keNan" {
                self.downLoadBtn.setTitle("Finished", for: .normal)
                self.downLoadBtn.isUserInteractionEnabled = false
            } else if yagor.directoryName == "zhuBaJie" {
                self.downLoadBtn1.setTitle("Finished", for: .normal)
                self.downLoadBtn1.isUserInteractionEnabled = false
            } else {
                self.downLoadBtn2.setTitle("Finished", for: .normal)
                self.downLoadBtn2.isUserInteractionEnabled = false
            }
        }
    }
    
    func videoDownloadFailed(by yagor: NicooYagor) {
        print("Video download failed. \(yagor.directoryName)")
    }
    
    func update(progress: Float, yagor: NicooYagor) {
        if yagor.directoryName == "keNan" {
            self.downLoadBtn.setTitle("\(progress * 100) %", for: .normal)
        } else if yagor.directoryName == "zhuBaJie" {
            self.downLoadBtn1.setTitle("\(progress * 100) %", for: .normal)
        } else {
            self.downLoadBtn2.setTitle("\(progress * 100) %", for: .normal)
        }
       
    }
    
}
