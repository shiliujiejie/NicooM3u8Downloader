//
//  NicooTsDownloader.swift
//  NicooM3u8Downloader
//
//  Created by pro5 on 2019/1/21.
//

import Foundation


protocol TSDownloaderDelegate {
    func tsDownloadSucceeded(with downloader: NicooTsDownloader)
    func tsDownloadFailed(with downloader: NicooTsDownloader)
}

class NicooTsDownloader: NSObject {
    var fileName: String
    var filePath: String
    var downloadURL: String
    var duration: Float
    var index: Int
    var failedIndexs = [Int]()
    
    lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    var downloadTask: URLSessionDownloadTask?
    var isDownloading = false
    var finishedDownload = false
    
    var delegate: TSDownloaderDelegate?
    
    init(with url: String, filePath: String, fileName: String, duration: Float, index: Int) {
        downloadURL = url
        self.filePath = filePath
        self.fileName = fileName
        self.duration = duration
        self.index = index
    }
    
    func startDownload() {
        if checkIfIsDownloaded() {
            finishedDownload = true
            
            delegate?.tsDownloadSucceeded(with: self)
        } else {
            let url = downloadURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            guard let taskURL = URL(string: url) else { return }
            
            downloadTask = downloadSession.downloadTask(with: taskURL)
            downloadTask?.resume()
            isDownloading = true
        }
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
        isDownloading = false
    }
    
    func pauseDownload() {
        if isDownloading {
            downloadTask?.suspend()
            
            isDownloading = false
        }
    }
    
    func resumeDownload() {
        downloadTask?.resume()
        isDownloading = true
    }
    
    func checkIfIsDownloaded() -> Bool {
        let filePath = generateFilePath().path
        
        if FileManager.default.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    func generateFilePath() -> URL {
        let path = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile).appendingPathComponent(filePath).appendingPathComponent(fileName)
        return path
    }
}

extension NicooTsDownloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let destinationURL = generateFilePath()
        finishedDownload = true
        isDownloading = false
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return
        } else {
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                delegate?.tsDownloadSucceeded(with: self)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            finishedDownload = false
            isDownloading = false
            
//            let path = getDocumentsDirectory()
//            let failedPath = path.appendingPathComponent("Downloads").appendingPathComponent(filePath).appendingPathComponent(fileName)
//            
//                
//                
//               // UserDefaults.standard.set(path, forKey: "DownLoadFialedUrl")
          
            
            print("didCompleteWithError")
            delegate?.tsDownloadFailed(with: self)
        }
    }
    
}
