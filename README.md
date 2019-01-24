# NicooM3u8Downloader

<p align="center">
<img src="https://github.com/yangxina/Application/blob/master/nicooM3u8downloader.png" width=1000 />
</p>

[![CI Status](https://img.shields.io/travis/yangxina/NicooM3u8Downloader.svg?style=flat)](https://travis-ci.org/yangxina/NicooM3u8Downloader)
[![Version](https://img.shields.io/cocoapods/v/NicooM3u8Downloader.svg?style=flat)](https://cocoapods.org/pods/NicooM3u8Downloader)
[![License](https://img.shields.io/cocoapods/l/NicooM3u8Downloader.svg?style=flat)](https://cocoapods.org/pods/NicooM3u8Downloader)
[![Platform](https://img.shields.io/cocoapods/p/NicooM3u8Downloader.svg?style=flat)](https://cocoapods.org/pods/NicooM3u8Downloader)


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

最近在做视频播放器，发现目前主流的视频播放都是流媒体，以前的MP4 大文件播放时代已经过去了。之前做的一个播放器：   

https://github.com/yangxina/NicooPlayer 

在此之前没有支持m3u8流媒体播放，现在也已经兼容了m3u8流媒体播放。 不过当前正在处理流媒体的断点续传。边下边播。

- 首先，边下边播的好处就不多说了，比起从服务器直接拉取数据流播放，显得更加流畅，用户体验更加爽。要做边下边播，那肯定要先玩会 流媒体下载。 NicooM3u8Downloader这个组件就是针对流媒体下载封装的一个组件。

- 封装思路

(1) 在线解析m3u8文件内容,把里面的ts对应连接的资源下载本地的Document文件下。

(2) 把下载下来的资源使用本地路径重新拼接成一个新的本地m3u8文件。

(3) 然后在开启一个本地http服务端，把m3u8共享成连接地址，让播放器播放。

- (1).m3u8的解析：

   在做m3u8文件在线解析之前，必须要对m3u8文件格式，文件规则，文本键值对作用，意义有一定的了解。 这里就不对 m3u8 做过多解释，需  
   要了解的同学请查看博客: https://blog.csdn.net/blueboyhi/article/details/40107683
   本人在做这一块时，也是先去研读了这篇博客。给博客作者点个👍。 另外还要了解一下 .ts 后缀的视频片段文件，.ts文件就是你播放的视频文件，不过每一个ts  
   视频文件的长度都很短，一般就只有几秒钟，长点的也就几十秒。 这里不做多解释，可以自行去查资料。
   
   了解完了m3u8之后，就知道，m3u8 有可能是一层，或者两层。（不会再多，游戏规则说的是最多包一层，也就是最多两层）。
   
   m3u8一层： 
   
   如果m3u8已有一层，那么第一此解析出来就会带有 xxx.ts流路径的m3u8文件内容。 例如我们将一个视频url：如（http://xxx/yyy/zzz/sss.m3u8）
   解析处理的文件内容。
   如下： 
   
      #EXTM3U
      #EXT-X-VERSION:3
      #EXT-X-MEDIA-SEQUENCE:0
      #EXT-X-ALLOW-CACHE:YES
      #EXT-X-TARGETDURATION:21
      #EXTINF:19.263833,
      d104cd51ca787c02b4ceaf084801ace4_free_0000.ts
      #EXTINF:8.000000,
      d104cd51ca787c02b4ceaf084801ace4_free_0001.ts
      #EXTINF:3.260867,
      d104cd51ca787c02b4ceaf084801ace4_free_0002.ts
      #EXTINF:20.043478,
      d104cd51ca787c02b4ceaf084801ace4_free_0003.ts
      #EXTINF:2.782611,
      d104cd51ca787c02b4ceaf084801ace4_free_0004.ts
      ....(- 中间省略95行 - )
      #EXTINF:10.869567,
      d104cd51ca787c02b4ceaf084801ace4_free_0100.ts
      #EXT-X-ENDLIST
     
   可以看到，这里解析出来的 xxx.ts : d104cd51ca787c02b4ceaf084801ace4_free_0002.ts, 不是一个可以直接下载的全路径。
   这时候，需要将这个ts下载下来，就需要拼接一个正确的下载地址。这时候就需要对拿来解析的视频url进行路径切片。比如： http://xxx/yyy/zzz/sss.m3u8
   这个url。
   我们需要把它切成：
   
    [ http://xxx, 
      http://xxx/yyy,
      http://xxx/yyy/zzz  ] 
    
   这样3个路径，然后将我们解析出来的xxx.ts,分别拼接到3个路径后，生成3 
   个ts文件下载路径.(其中只有一个是有效的url), 我们需要从这3个（有可能是N个）中找到那个可以下载ts的有效url. 在组件内，我是直接每一个都拼接文件中
   第一个ts,然后分别拿去做一次下载，下载到的第一个ts数据不为空，就表示当前这个url是有效的。当我们拿到了有效的ts下载路径，我们只需要创建下载任务去下
   载这些ts文件，存放到本地一个文件夹内。

   m3u8两层：
   
   两层的m3u8解析，其实也就是在一层的基础上，多做一次解析，当然我们要判断第一次解析没有解析出来ts列表，才会做第二层解析。这里拿个例子来说：
   比如我们要解析： http://youku.com-www-163.com/20180506/576_bf997390/index.m3u8 这个视频地址。 第一层解析出来内容如下：
   
     "#EXTM3U\n#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=800000,RESOLUTION=1080x608\n1000k/hls/index.m3u8"
     
   什么？？ 解析出来没有ts路径，莫慌。虽然没看到.ts 文件路径，但是我们看到 ”#EXT-X-STREAM-INF:“ 这个，看到这玩意儿，表示我们还需要在解析一次。   
   那么，问题又来了：
   
   第二次解析，我们解析哪个url? 
   
   第一次解析出来的内容里面没有啊！！！
   
   不， 是有的。
   
   我们看到最后有个： RESOLUTION=1080x608\n1000k/hls/index.m3u8 ，我们需要把这个带.m3u8后缀的东西，以 "\n" (换行符) 切开。   
   拿到带有.m3u8后缀的一段。也就是： 1000k/hls/index.m3u8 
   
   但是，我们拿到的只是后缀，前面的路径是什么？
   
   我也不知道！
   
   那怎么办？
   
   一个一个试呗！ （当然这里的试不是手动试，是写程序一个一个去请求试。）
   
   这里我们就会用到一层解析，拼接有效ts路径的思路。  这里我们需要，将 http://youku.com-www-163.com/20180506/576_bf997390/index.m3u8 
   视频url切片成： 
         
    [ http://youku.com-www-163.com, 
     http://youku.com-www-163.com/20180506,
     http://youku.com-www-163.com/20180506/576_bf997390 ]
        
   这样的一个数组，然后拼接  1000k/hls/index.m3u8 到他们后面，得到
   
     [ http://youku.com-www-163.com/1000k/hls/index.m3u8,
       http://youku.com-www-163.com/20180506/1000k/hls/index.m3u8, 
       http://youku.com-www-163.com/20180506/576_bf997390/1000k/hls/index.m3u8  ] 
   
   三个里层url,当然这里面也只有一个试正确的，能够解析到.ts列表的。 这样我们只需要依次去解析每一个。 如果谁能解析出来，谁就是真的。
   这里判断是否解析出来.ts列表，可以验证解析出来的内容 是否有包含 “#EXTINF:” 或者是否包含 ”.ts“, 个人建议用第一个来判断。
   解析到了.ts路径列表，那么，我们就可以直接创建任务去下载了。
   
   别急，没那个简单。
   
   上面说的只是没有加密的.m3u8解析。 一般情况下，我们会在里面加一些骚操作的。（加密）
   一般我们会在m3u8文件中植入加密，常用的 AES-128,对称加密。 这种最常见。 别的还没碰到。碰到了在更新组件。
   一般加密的m3u8解析出来长这样： 
  
      #EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:11\n#EXT-X-MEDIA-SEQUENCE:0\n#EXT-X-KEY:METHOD=AES-128,URI=\"http://xinyuan.zeikcdn.com/20180616/LQfzeEFU/800kb/hls/key.key\"\n#EXTINF:6.839,\nhttp://xinyuan.zeikcdn.com/20180616/LQfzeEFU/800kb/hls/PJy4h6573000.jpg\n#EXTINF:8.59,\nhttp://xinyuan.zeikcdn.com/20180616/LQfzeEFU/800kb/hls/PJy4h6573001.jpg\n#EXTINF:6.547,\nhttp://xinyuan.zeikcdn.com/20180616/LQfzeEFU/800kb/hls/PJy4h6573002.jpg\n
    
   我们看到里面有这样一段： #EXT-X-KEY:METHOD=AES-128,URI=\"http://xinyuan.zeikcdn.com/20180616/LQfzeEFU/800kb/hls/key.key\"
   我们可以看出使用了 AES-128 对称加密。 既然加了密，我们怎么办？
   别急，m3u8 想播放器能播放，肯定会有对应的操作的； 我们这里看到一个 ”URI=“ 后面是一个 http://xxx/yyy/sss.key 的路径，很奇怪。 这让我们联想
   到 密钥。 对。没错。 就是它。 这个路径就是密钥的下载地址。 我们需要将它下载下来存放到本地。 记录下来它的本地路径。 最好和下载的 .ts文件一个目  
   录。
   
   上面说的加密还没有涉及到 IV。
   
   什么？ IV又是什么鬼？
   
   别慌，IV的处理很简单，有些密钥中没有，有些有： 有IV的key长这样: 
   
    #EXT-X-KEY:METHOD=AES-128,URI=\"http://xinyuan.zeikcdn.com/20180616/LQfzeEFU/800kb/hls/key.key\",IV=b66cb67a9bfd78ed
   URI后面多了一个东西。 只需要将这一串 b66cb67a9bfd78ed 抠出来。在后面编写本地.m3u8文件时填入，就行了。
   到这里，m3u8的解析就完了。
   
   解析完了，拿到了ts的下载路径，那么ts流视频的下载也就简单了，开一堆下载任务，异步去执行ts文件的下载。这里就不做讲解了。就是下载到一个本地文件夹里面。下面我要讲的是：
   
- (2)本地m3u8文件创建   
   
1.本地m3u8文件创建。 2.本地服务器的搭建。
  
  1.本地m3u8文件创建。
     创建本地文件：
     
     /// 创建本地M3u8文件，播放要用
      func createLocalM3U8file() {
          NicooDownLoadHelper.checkOrCreatedM3u8Directory(tsPlaylist.identifier)
        let filePath =           NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile).appendingPathComponent(tsPlaylist.identifier).appendingPathComponent("\(tsPlaylist.identifier).m3u8")
        
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
   
   这里不好文字描述，就上代码。 反正记住两个东西： 1. 解析下载的密钥文件的相对路径，一定要写入文件， 2. 有IV的要将IV也拼接到后面。
   
   代码如下：
   
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
    
   这样就只需要等异步下载的ts下载完成了。 
   
   --- warning:（这里需要提一下的是： 组件中只是针对下载，所以在下载之前就将本地.m3u8文件创建好了。
   如果是要做播放器的断点续传。 这里需要每下载完一个 .ts 文件,就更新一次本地 .m3u8 文件。而且没有下载完成的ts文件，不能写入.m3u8 文件中。 只能开
   定时器，每多少秒去复制本地文件夹一次，供给播放器使用。）
   
   
   
 - (3) 本地服务器搭建，播放本地视频。
 
 这个我使用了 CocoaHTTPServer 这个框架来搭建本地服务器。 播放器使用自己的播放器： NicooPlayer 
 代码： 
 
     private func playLocalVideo() {
        server = HTTPServer()
        server.setType("_http.tcp")
        server.setDocumentRoot(NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile).appendingPathComponent(videoName).path)
   

     print("localFilePath = \(NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile).path)")
     
        server.setPort(UInt16(port))
        
        do {
            try server.start()
        }catch{
            print("本地服务器启动失败")
        }
        let videoLocalUrl = "\(getLocalServerBaseUrl()):\(port)/\(videoName).m3u8"
        videoPlayer.playLocalVideoInFullscreen(videoLocalUrl, "localFile", view, sinceTime: 0)
        videoPlayer.playLocalFileVideoCloseCallBack = { [weak self] (playValue) in
            // 退出时，关闭本地服务器
            self?.server.stop()
            self?.navigationController?.popViewController(animated: false)
        }
    }
        
   到这里，m3u8流视频下载和本地播放，就做完了。
   
   🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏
   
   如果觉得有用的朋友，望不吝赐赏，小弟将感激不尽 🙏，并祝你合家欢乐，新年快乐，万事如意。
   
   🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏
   



## Installation

NicooM3u8Downloader is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NicooM3u8Downloader'
```

## Author

yangxina, 504672006@qq.com

## License

NicooM3u8Downloader is available under the MIT license. See the LICENSE file for more info.
