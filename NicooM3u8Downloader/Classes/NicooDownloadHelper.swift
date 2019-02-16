//
//  NicooDownloadHelper.swift
//  NicooM3u8Downloader
//
//  Created by pro5 on 2019/1/21.
//

import Foundation

open class NicooDownLoadHelper: NSObject {
    // Downloads   && Nicoo_M3u8_Downloads
    public static let downloadFile = "Downloads"
    
    open class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    open class func checkOrCreatedM3u8Directory(_ identifer: String) {
        let filePath = getDocumentsDirectory().appendingPathComponent(downloadFile).appendingPathComponent(identifer)
        if !FileManager.default.fileExists(atPath: filePath.path) {
            try? FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// 根据正则表达式  截取字符串 ：pattern： 正则字符串  str: 被截取字符串
    open class func regexGetSub(pattern: String, str: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options:[])
        let matches = regex.matches(in: str, options: [], range: NSRange(str.startIndex...,in: str))
        if matches.count > 0 {
            let ss = str[Range(matches[0].range(at: 1), in: str)!]
            let sttss = ss.components(separatedBy: "\"")
            for string in sttss {
                if string.contains("http") {
                    return string
                }
            }
        }
        return ""
    }
}




