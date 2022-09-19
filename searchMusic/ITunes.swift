//
//  ITunes.swift
//  searchMusic
//
//  Created by Ya Yu Yeh on 2022/9/18.
//

import Foundation
struct ITunesResponse:Decodable{
    var results:[ITunes]
}

struct ITunes:Decodable, Equatable{
    //歌手
    var artistName:String
    //音樂片段播放
    var previewUrl:URL
    //發布日期_2020-10-23T07:00:00Z
    var releaseDate:Date
}
