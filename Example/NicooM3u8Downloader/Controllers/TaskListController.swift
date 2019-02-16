//
//  TaskListController.swift
//  NicooM3u8Downloader_Example
//
//  Created by pro5 on 2019/2/16.
//  Copyright © 2019年 CocoaPods. All rights reserved.
//

import UIKit
import NicooM3u8Downloader

class TaskListController: UIViewController {
    
    let urls: [String] = ["http://youku.com-www-163.com/20180506/576_bf997390/index.m3u8","https://www3.yuboyun.com/hls/2018/11/25/SmRqndpr/playlist.m3u8","http://yun.kubo-zy-youku.com/20181112/BULbB7PC/index.m3u8"]
    let names: [String] = ["kenan","dotNot","weiLaizhisheng"]
    
    lazy var yagorList: [NicooYagor] = {
        var yagors = [NicooYagor]()
        for i in  0 ..< urls.count {
            let yagor = NicooYagor()
            yagor.directoryName = names[i]
            yagor.m3u8URL = urls[i]
            yagor.delegate = self
            yagor.parse()
            yagors.append(yagor)
        }
        return yagors
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: view.bounds, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.separatorStyle = .none
        table.register(DownloadTaskListCell.classForCoder(), forCellReuseIdentifier: DownloadTaskListCell.cellId)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        layoutPageSubviews()
    }
    


}

// MARK: - YagorDelegate
extension TaskListController: YagorDelegate {
    
    func videoDownloadSucceeded(by yagor: NicooYagor) {
        let filePath = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile)
        print("downLoadFilePath = \(filePath). videoFileName = \(yagor.directoryName)")
        DispatchQueue.main.async {
            if yagor.directoryName == "keNan" {
              
            } else if yagor.directoryName == "zhuBaJie" {
              
            } else {
               
            }
        }
    }
    
    func videoDownloadFailed(by yagor: NicooYagor) {
        print("Video download failed. \(yagor.directoryName)")
    }
    
    func update(progress: Float, yagor: NicooYagor) {
        tableView.reloadData()
    }
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension TaskListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yagorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DownloadTaskListCell.cellId, for: indexPath) as! DownloadTaskListCell
        let yagor = yagorList[indexPath.row]
        if yagor.progress > 0 {
            cell.percentageLable.text = "\(yagor.progress * 100) %"
            cell.progressView.progress = yagor.progress
            if yagor.downloader.downloadStatus == .paused {
                cell.statuButton.setTitle("开始", for: .normal)
            } else if yagor.downloader.downloadStatus == .started {
                cell.statuButton.setTitle("暂停", for: .normal)
            } else if yagor.downloader.downloadStatus == .finished {
                cell.statuButton.setTitle("完成", for: .normal)
            }
        }
        cell.downLoadStatuButtonClick = { [weak self] (sender) in
            if yagor.downloader.downloadStatus == .paused {
                yagor.resumeDownloadSegment()
            } else if yagor.downloader.downloadStatus == .started {
                yagor.pauseDownloadSegment()
            } else if yagor.downloader.downloadStatus == .finished {
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let localPlayVC = DownLoadedVideoPlayerVC()
        localPlayVC.videoName = names[indexPath.row]
        navigationController?.pushViewController(localPlayVC, animated: true)
    }
    
//    // 每个cell中的状态更新，应该在willDisplay中执行
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let yagor = yagorList[indexPath.row]
//
//        configTask(yagor: yagor, cell: cell as! DownloadTaskListCell, visible: true)
//    }
//
//    // 由于cell是循环利用的，不在可视范围内的cell，不应该去更新cell的状态
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//       let yagor = yagorList[indexPath.row]
//
//        configTask(yagor: yagor, cell: cell as! DownloadTaskListCell, visible: false)
//    }
//
//    /// 单个任务下载完成或者其他
//    func configTask(yagor: NicooYagor, cell: DownloadTaskListCell, visible: Bool) {
//        cell.percentageLable.text = "\(yagor.progress * 100) %"
//        cell.progressView.progress = yagor.progress
//        if yagor.downloader.downloadStatus == .paused {
//            yagor.resumeDownloadSegment()
//            cell.statuButton.setTitle("暂停", for: .normal)
//        } else if yagor.downloader.downloadStatus == .started {
//            yagor.pauseDownloadSegment()
//            cell.statuButton.setTitle("开始", for: .normal)
//        } else if yagor.downloader.downloadStatus == .finished {
//            cell.statuButton.setTitle("完成", for: .normal)
//        }
//    }
    
}


private extension TaskListController {
    
    func layoutPageSubviews() {
        layoutTableView()
    }
    
    func layoutTableView() {
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
            } else {
                make.edges.equalToSuperview()
            }
        }
    }
    
}
