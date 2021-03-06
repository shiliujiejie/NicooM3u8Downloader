//
//  NicooM3u8Parser.swift
//  NicooM3u8Downloader
//
//  Created by pro5 on 2019/1/21.
//

import Foundation

/// m3u8解析协议
protocol M3u8ParserDelegate: class {
    func parseM3u8Succeeded(by parser: NicooM3u8Parser)
    func parseM3u8Failed(by parser: NicooM3u8Parser)
}

/// M3U8解析器 ，这里只做了两种常规的 m3u8解析。 对于自己服务器的加密，或者其他玩法的m3u8解析，这里需要自己去处理， 时间紧，先不写代理， g下个版本会，写一个回调在外部让你们自己去玩，加密等骚操作。
open class NicooM3u8Parser: NSObject {
    /// m3u8文件解析出来的文本字符串
    var m3u8Data: String = ""
    /// ts列表
    var tsModels = [NicooTsModel]()
    /// ts列表Model
    var tsListModel = NicooTsListModel()
    /// 标识符
    var identifier: String = ""
    /// Url Header 用于两层m3u8解析时， 拼接第二次解析的Url
    var urlHeader: String = ""
    
    /// 用于保存第一次解析前对 url Layer 的切片
    var urlM3u8Headers = [String]()
    /// 第二次解析，需要尝试解析的Urls
    var secondParseUrls = [String]()
    /// 用于保存第二次解析成功，筛选出来的有效的URL 切片
    var urlTsHeaders = [String]()
    
    /// 第一次解析出来的.m3u8后缀
    var lastM3u8File: String = ""
    
    
    weak var delegate: M3u8ParserDelegate?
    
    /// 解析第一层m3u8
    ///
    /// - Parameter url: 第一层url ,唯一一个，不需要尝试拼接
    func parseFirstLayerM3u8(_ url: String) {
        guard let m3u8ParserDelegate = delegate else { return }
        if !(url.hasPrefix("http://") || url.hasPrefix("https://")) {
            print("Invalid http URL.(无效的URL链接)")
            m3u8ParserDelegate.parseM3u8Failed(by: self)
            return
        }
        // 将layerUrl 切片，为后面拼接用
        getM3u8UrlHeader(url)
        
        DispatchQueue.global(qos: .background).async {
            do {
                /// 尝试将layer url 解析成字符串
                let layerM3u8Content = try String(contentsOf: URL(string: url)!, encoding: .utf8)
                if layerM3u8Content.isEmpty {
                    m3u8ParserDelegate.parseM3u8Failed(by: self)
                    return
                } else {
                    /// 第一层就解析到了ts流
                    if layerM3u8Content.range(of: "#EXTINF:") != nil {
                        print("<Layer> m3u8 can be parse, start parsing.(m3u8解析 - 修成正果)")
                        self.getTsDownloadUrlHeader(url)
                        self.sepalateRealM3u8List(layerM3u8Content, url)
                    }
                    /// 第一层解析出来没有ts流，说明有2层，解析第二层
                    if layerM3u8Content.range(of: "#EXT-X-STREAM-INF:") != nil {
                        print("<Layer> m3u8 can not be parse, parse again.")
                        var m3u8String = ""
                        let lastM3u8pes = layerM3u8Content.components(separatedBy: "\n")
                        /// 获取带.m3u8后缀的切片
                        for stringPs in lastM3u8pes {
                            if stringPs.contains(".m3u8") {
                                m3u8String = stringPs
                                self.lastM3u8File = stringPs
                            }
                        }
                        /// 拼接批量二次解析需要的第二层m3u8Url
                        if !m3u8String.isEmpty {
                            for header in self.urlM3u8Headers {
                                var realM3u8Url = ""
                                if m3u8String.hasPrefix("/") {
                                    realM3u8Url = String(format: "%@%@", header, m3u8String)
                                } else {
                                    realM3u8Url = String(format: "%@/%@", header, m3u8String)
                                }
                                print("secondParseUrl m3u8：\(realM3u8Url)")
                                self.secondParseUrls.append(realM3u8Url)
                            }
                            /// 第二次解析
                            self.parseDepthM3u8()
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
                print("<Layer> m3u8 file content first read error. \(url)")
                self.delegate?.parseM3u8Failed(by: self)
            }
        }
    }
    
    /// 第二次解析, 尝试去解析每一个可能的Url,只要解析到，并且包含ts流,取出ts
    func parseDepthM3u8() {
        DispatchQueue.global().async {
            do {
                var depthContent = ""
                for depthParseUrl in self.secondParseUrls {
                    if let depthM3u8Content = try? String(contentsOf: URL(string: depthParseUrl)!, encoding: .utf8) {
                        // 解析到
                        if !depthM3u8Content.isEmpty {
                            /// 解析到了ts流
                            if depthM3u8Content.range(of: "#EXTINF:") != nil {
                                print("<Depth> m3u8 url: \n \(depthParseUrl) \n can be parse, start parsing.(m3u8解析 - 修成正果)")
                                depthContent = depthM3u8Content
                                self.getTsDownloadUrlHeader(depthParseUrl)
                                self.sepalateRealM3u8List(depthM3u8Content, depthParseUrl)
                            } else {
                                print("<Depth> m3u8 parse failed!")
                                self.delegate?.parseM3u8Failed(by: self)
                            }
                        }
                    } else {
                        print("<Depth> m3u8 parse failed!,Invalid m3u8 URL :\(depthParseUrl) ")
                    }
                }
                if depthContent.isEmpty {
                    // 解析失败
                    print("<Depth> m3u8 parse failed!")
                    self.delegate?.parseM3u8Failed(by: self)
                }
            }
        }
    }
   

}

// MARK: - Private funcs
private extension NicooM3u8Parser {
    
    /// 第一次切片Url
    ///
    /// - Parameter url: Layer .m3u8 url
    func getM3u8UrlHeader(_ url: String) {
        let headerPaths = url.components(separatedBy: "/")
        if headerPaths.count <= 3 {
            return
        }
        var headerUtlPath = ""
        if let lastStr = headerPaths.last {
            if var depthM3u8Header = url.components(separatedBy: lastStr).first {
                if depthM3u8Header.hasSuffix("/") {
                    depthM3u8Header.remove(at: depthM3u8Header.index(before: depthM3u8Header.endIndex))
                }
                urlM3u8Headers.append(depthM3u8Header)
                headerUtlPath = depthM3u8Header
            }
        }
        getM3u8UrlHeader(headerUtlPath)
    }
    
    /// 第二次切片Url: 为ts的下载地址做准备（如果ts列表是全路径，则不需要）
    ///
    /// - Parameter url: Depth .m3u8 url
    func getTsDownloadUrlHeader(_ url: String) {
        let headerPaths = url.components(separatedBy: "/")
        if headerPaths.count <= 3 {
            //urlTsHeaders.append(tsUrlHeader)
            return
        }
        var headerUtlPath = ""
        if let lastStr = headerPaths.last {
            if var tsUrlHeader = url.components(separatedBy: lastStr).first {
                if tsUrlHeader.hasSuffix("/") {
                    tsUrlHeader.remove(at: tsUrlHeader.index(before: tsUrlHeader.endIndex))
                }
                urlTsHeaders.append(tsUrlHeader)
                headerUtlPath = tsUrlHeader
            }
        }
        getTsDownloadUrlHeader(headerUtlPath)
    }
    
}

// MARK: - Privite Funcs
private extension NicooM3u8Parser {
    
    /// 下载秘钥
    ///
    /// - Parameter m3u8Content: 带ts列表的有效 m3u8Content
    func downLoadKeyWith(_ m3u8Content: String) {
        if !m3u8Content.contains("#EXT-X-KEY:") { return }
        var keySttr = ""
        // 用正则表达式取出秘钥所在 url
        keySttr = NicooDownLoadHelper.regexGetSub(pattern: "URI=\"(.+?)\"", str: m3u8Content)
        if !keySttr.isEmpty {
            print("DownLoad KEY file by URI = \(keySttr) ")
            if let dataKey = try? Data(contentsOf: URL(string: keySttr)!) {
                NicooDownLoadHelper.checkOrCreatedM3u8Directory(self.identifier)
                let filePath = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile).appendingPathComponent(self.identifier).appendingPathComponent("key")
                print("Local path for KEY file = \(filePath) ")
                if !FileManager.default.fileExists(atPath: filePath.path) {
                    print("KEY file is not exist, download and save to: \(filePath) ")
                    let success = FileManager.default.createFile(atPath: filePath.path, contents: dataKey, attributes: nil)
                    if success {
                        print("key write to file Succeeded")
                    } else {
                        print("key file write to file Failed! =\(dataKey.count)")
                    }
                }
            } else {
                print("KEY file download failed")
            }
        }
    }
    
    /// 尝试去拼接路径下载第一个ts,如果下载成功，则表示路径拼对了，将正确路径的前缀返给每个Ts model
    func tryToGetRightTsPath(_ tsLastUrl: String) -> String? {
        for tsUrlHeader in urlTsHeaders {
            var maybeRightUrl = ""
            if tsLastUrl.hasPrefix("/") {
                maybeRightUrl = String(format: "%@%@", tsUrlHeader,tsLastUrl)
            } else {
                maybeRightUrl = String(format: "%@/%@", tsUrlHeader,tsLastUrl)
            }
            if let _ = try? Data(contentsOf: URL(string: maybeRightUrl)!) {
                print("correct Ts downloadUrl = \(maybeRightUrl)")
                return tsUrlHeader
            } else {
                print("current TS download url is not correct.:\(maybeRightUrl)")
            }
        }
        return nil
    }
    
    /// 拆分m3u8文件，取出ts 和秘钥等
    func sepalateRealM3u8List(_ m3u8Content: String, _ url: String) {
        self.m3u8Data = m3u8Content
        if tsModels.count > 0 { tsModels.removeAll() }
        downLoadKeyWith(m3u8Content)
      
        let segmentRange = m3u8Content.range(of: "#EXTINF:")!
        let segmentsString = String(m3u8Content.characters.suffix(from: segmentRange.lowerBound)).components(separatedBy: "#EXT-X-ENDLIST")
        var segmentArray = segmentsString[0].components(separatedBy: "\n")
        segmentArray = segmentArray.filter { !$0.contains("#EXT-X-DISCONTINUITY") }
        var rightTsUrl = ""
        if segmentArray.count > 2 {
            let segmentURL = segmentArray[1]
            /// ts 路径非全路径
            if !(segmentURL.hasPrefix("http://") || segmentURL.hasPrefix("https://")) {
                // 拼接url 全路劲
                rightTsUrl = tryToGetRightTsPath(segmentURL) ?? ""
                if rightTsUrl.isEmpty {
                    print("The correct ts download url was not found, maybe download failed.")
                    //return
                }
            }
        }
        
        /// 分割 m3u8文件，拼接TS model
        while (segmentArray.count > 2) {
            var segmentModel = NicooTsModel()
            let segmentDurationPart = segmentArray[0].components(separatedBy: ":")[1]
            var segmentDuration: Float = 0.0
            
            if segmentDurationPart.contains(",") {
                segmentDuration = Float(segmentDurationPart.components(separatedBy: ",")[0])!
            } else {
                segmentDuration = Float(segmentDurationPart)!
            }
            segmentModel.duration = segmentDuration
            var segmentURL = segmentArray[1]
            /// ts 路径非全路径
            if !(segmentURL.hasPrefix("http://") || segmentURL.hasPrefix("https://")) {
                // 拼接url 全路劲
                if segmentURL.hasPrefix("/") {
                    segmentURL = String(format: "%@%@", rightTsUrl,segmentURL)
                } else {
                    segmentURL = String(format: "%@/%@", rightTsUrl,segmentURL)
                }
            }  
            segmentModel.locationUrl = segmentURL
            tsModels.append(segmentModel)
            segmentArray.remove(at: 0)
            segmentArray.remove(at: 0)
        }
        tsListModel.initTsList(with: tsModels)
        tsListModel.identifier = identifier
        self.delegate?.parseM3u8Succeeded(by: self)
    }
    
    
}
