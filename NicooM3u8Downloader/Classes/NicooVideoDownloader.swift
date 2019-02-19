//
//  NicooVideoDownloader.swift
//  NicooM3u8Downloader
//
//  Created by pro5 on 2019/1/21.
//

import Foundation

public enum Status {
    case started
    case paused
    case canceled
    case finished
    case failed
}

/// 下载成功失败， 进度 回调
protocol VideoDownloaderDelegate {
    func videoDownloadSucceeded(by downloader: VideoDownloader)
    func videoDownloadFailed(by downloader: VideoDownloader)
    
    func update(progress: Float, downloader: VideoDownloader)
}

open class VideoDownloader {
    public var downloadStatus: Status = .paused
    
    var m3u8Data: String = ""
    var tsPlaylist = NicooTsListModel()
    var segmentDownloaders = [NicooTsDownloader]()
    var tsFilesIndex = 0
    var neededDownloadTsFilesCount = 0
    var downloadURLs = [String]()
    var downloadingProgress: Float {
        let finishedDownloadFilesCount = segmentDownloaders.filter({ $0.finishedDownload == true }).count
        let fraction = Float(finishedDownloadFilesCount) / Float(neededDownloadTsFilesCount)
        let roundedValue = round(fraction * 100) / 100
        
        return roundedValue
    }
    
    fileprivate var startDownloadIndex = 2
    
    var delegate: VideoDownloaderDelegate?
    
    open func startDownload() {
        NicooDownLoadHelper.checkOrCreatedM3u8Directory(tsPlaylist.identifier)
        
        var newSegmentArray = [NicooTsModel]()
        
        let notInDownloadList = tsPlaylist.tsModelArray.filter { !downloadURLs.contains($0.locationUrl) }
        neededDownloadTsFilesCount = tsPlaylist.length
        
        for i in 0 ..< notInDownloadList.count {
            let fileName = "\(tsFilesIndex).ts"
            
            let segmentDownloader = NicooTsDownloader(with: notInDownloadList[i].locationUrl,
                                                      filePath: tsPlaylist.identifier,
                                                      fileName: fileName,
                                                      duration: notInDownloadList[i].duration,
                                                      index: tsFilesIndex)
            segmentDownloader.delegate = self
            
            segmentDownloaders.append(segmentDownloader)
            downloadURLs.append(notInDownloadList[i].locationUrl)
            
            var segmentModel = NicooTsModel()
            segmentModel.duration = segmentDownloaders[i].duration
            segmentModel.locationUrl = segmentDownloaders[i].fileName
            segmentModel.index = segmentDownloaders[i].index
            newSegmentArray.append(segmentModel)
            
            tsPlaylist.tsModelArray = newSegmentArray
            
            tsFilesIndex += 1
        }
        createLocalM3U8file()
        
        segmentDownloaders[0].startDownload()
        segmentDownloaders[1].startDownload()
        segmentDownloaders[2].startDownload()
        
        downloadStatus = .started
    }
    
    func checkDownloadQueue() {
        
    }
    
    /// 获取解密字符串
    ///
    /// - Returns: 解密字符串IV
    func getIV() -> String? {
        if !m3u8Data.contains("#EXT-X-KEY:") { return nil }
        // 用正则表达式取出秘钥所在 url
        let m3u8Pes = m3u8Data.components(separatedBy: "\n")
        var keyM3u8 = ""
        for pes in m3u8Pes {
            if pes.contains("IV=") && pes.contains("#EXT-X-KEY:") {
                keyM3u8 = pes.components(separatedBy: "IV=").last ?? ""
            }
        }
        if !keyM3u8.isEmpty {
            return keyM3u8
        }
        return nil
    }
    
    /// 创建本地M3u8文件，播放要用
    func createLocalM3U8file() {
        NicooDownLoadHelper.checkOrCreatedM3u8Directory(tsPlaylist.identifier)
        
        let filePath = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile).appendingPathComponent(tsPlaylist.identifier).appendingPathComponent("\(tsPlaylist.identifier).m3u8")
        
        /// 解密的key 所在的路径和ts视频片段在同一文件目录下，所以这里直接用相对路径，如果不在一个文件夹下，需要拼接绝对路径
        let keyPath = "key"
        ///绝对路径
        let keyPathAll = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile).appendingPathComponent(tsPlaylist.identifier).appendingPathComponent("key")
        var header = "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:60\n"
        if m3u8Data.contains("#EXT-X-KEY:") && FileManager.default.fileExists(atPath: keyPathAll.path) {
            var keyStringPath = String(format: "#EXT-X-KEY:METHOD=AES-128,URI=\"%@\"", keyPath)
            if getIV() != nil {
                keyStringPath = String(format: "#EXT-X-KEY:METHOD=AES-128,URI=\"%@\",IV=%@", keyPath,getIV()!)
            }
            header = String(format: "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:60\n%@\n", keyStringPath)
            
        }
        var content = ""
        
        for i in 0 ..< tsPlaylist.tsModelArray.count {
            let segmentModel = tsPlaylist.tsModelArray[i]
            let length = "#EXTINF:\(segmentModel.duration),\n"
            let fileName = "\(segmentModel.index).ts\n"
            content += (length + fileName)
        }
        
        header.append(content)
        header.append("#EXT-X-ENDLIST\n")
        
        let writeData: Data = header.data(using: .utf8)!
        try! writeData.write(to: filePath)
    }
//    open func checkOrCreatedM3u8Directory() {
//        let filePath = getDocumentsDirectory().appendingPathComponent("Downloads").appendingPathComponent(tsPlaylist.identifier)
//        if !FileManager.default.fileExists(atPath: filePath.path) {
//            try! FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
//        }
//    }
    
    func pauseDownloadSegment() {
        _ = segmentDownloaders.map { $0.pauseDownload() }
        downloadStatus = .paused
    }
    
    func cancelDownloadSegment() {
        _ = segmentDownloaders.map { $0.cancelDownload() }
        downloadStatus = .canceled
    }
    
   func resumeDownloadSegment() {
        _ = segmentDownloaders.map { $0.resumeDownload() }
        downloadStatus = .started
    }
}

extension VideoDownloader: TSDownloaderDelegate {
    
    func tsDownloadSucceeded(with downloader: NicooTsDownloader) {
        let finishedDownloadFilesCount = segmentDownloaders.filter({ $0.finishedDownload == true }).count
        
        DispatchQueue.main.async {
            self.delegate?.update(progress: self.downloadingProgress, downloader: self)
        }
        
        let downloadingFilesCount = segmentDownloaders.filter({ $0.isDownloading == true }).count
        
        if finishedDownloadFilesCount == neededDownloadTsFilesCount {
            downloadStatus = .finished
            delegate?.videoDownloadSucceeded(by: self)
        } else if startDownloadIndex == neededDownloadTsFilesCount - 1 {
            if segmentDownloaders[startDownloadIndex].isDownloading == true { return }
        }
        else if downloadingFilesCount < 3 || finishedDownloadFilesCount != neededDownloadTsFilesCount {
            if startDownloadIndex < neededDownloadTsFilesCount - 1 {
                startDownloadIndex += 1
            }
            segmentDownloaders[startDownloadIndex].startDownload()
        }
    }
    
    func tsDownloadFailed(with downloader: NicooTsDownloader) {
        downloadStatus = .failed
        delegate?.videoDownloadFailed(by: self)
    }
}
