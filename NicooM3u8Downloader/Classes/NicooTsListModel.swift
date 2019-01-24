//
//  NicooTsListModel.swift
//  NicooM3u8Downloader
//
//  Created by pro5 on 2019/1/21.
//

import Foundation

/// ts视频片段列表model
class NicooTsListModel: NSObject {
    var tsModelArray = [NicooTsModel]()
    var length = 0
    var identifier: String = ""
    
    func initTsList(with tsList: [NicooTsModel]) {
        tsModelArray = tsList
        length = tsList.count
    }
}
