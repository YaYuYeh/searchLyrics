//
//  Lyrics.swift
//  searchMusic
//
//  Created by Ya Yu Yeh on 2022/9/18.
//

import Foundation
struct LyricsResponse:Decodable{
    //歌曲名稱
    var title:String?
    //歌手名稱
    var author:String?
    var lyrics:String?
    var thumbnail:Links?
    var links:Links?
    //thumbnail & links的key皆為genius，設為Links型別
    struct Links:Decodable{
        var genius:URL?
    }
}
