//
//  NicooYagor.swift
//  NicooM3u8Downloader
//
//  Created by pro5 on 2019/1/21.
//

import Foundation

public protocol YagorDelegate: class {
    func videoDownloadSucceeded(by yagor: NicooYagor)
    func videoDownloadFailed(by yagor: NicooYagor)
    
    func update(progress: Float, yagor: NicooYagor)
}

open class NicooYagor {
    public let downloader = VideoDownloader()
    public var progress: Float = 0.0
    public var directoryName: String = "" {
        didSet {
            m3u8Parser.identifier = directoryName
        }
    }
    public var m3u8URL = ""
    
    private let m3u8Parser = NicooM3u8Parser()
    
    public weak var delegate: YagorDelegate?
    
    public init() {
        
    }
    
    open func parse() {
        downloader.delegate = self
        m3u8Parser.delegate = self
        m3u8Parser.parseFirstLayerM3u8(m3u8URL)
        //m3u8Parser.parseM3u8(m3u8URL)
    }
    
    /// 删除所有下载
    open func deleteAllDownloadedContents() {
        let filePath = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile).path
        if FileManager.default.fileExists(atPath: filePath) {
            try! FileManager.default.removeItem(atPath: filePath)
        } else {
            print("File has already been deleted.")
        }
    }
    
    /// 根据名称删除已下载视频片段文件夹
    ///
    /// - Parameter name: 文件名
    open func deleteDownloadedContents(with name: String) {
        let filePath = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile).appendingPathComponent(name).path
        
        if FileManager.default.fileExists(atPath: filePath) {
            try! FileManager.default.removeItem(atPath: filePath)
        } else {
            print("Could not find directory with name: \(name)")
        }
    }
    
    open func pauseDownloadSegment() {
        downloader.pauseDownloadSegment()
    }
    
    open func cancelDownloadSegment() {
        downloader.cancelDownloadSegment()
    }
    
    open func resumeDownloadSegment() {
        downloader.resumeDownloadSegment()
    }

}

extension NicooYagor: M3u8ParserDelegate {
    func parseM3u8Succeeded(by parser: NicooM3u8Parser) {
        downloader.tsPlaylist = parser.tsListModel
        downloader.m3u8Data = parser.m3u8Data
        downloader.startDownload()
    }
    
    func parseM3u8Failed(by parser: NicooM3u8Parser) {
        print("Parse m3u8 file failed.")
        delegate?.videoDownloadFailed(by: self)
    }
}

extension NicooYagor: VideoDownloaderDelegate {
    
    func update(progress: Float, downloader: VideoDownloader) {
        self.progress = progress
        delegate?.update(progress: progress, yagor: self)
    }
    
    func videoDownloadSucceeded(by downloader: VideoDownloader) {
        delegate?.videoDownloadSucceeded(by: self)
    }
    
    func videoDownloadFailed(by downloader: VideoDownloader) {
        delegate?.videoDownloadFailed(by: self)
    }
  
}
