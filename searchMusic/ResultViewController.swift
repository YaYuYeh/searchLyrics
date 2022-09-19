//
//  ResultViewController.swift
//  searchMusic
//
//  Created by Ya Yu Yeh on 2022/9/18.
//

import UIKit
import Kingfisher
import SafariServices
import AVFoundation

class ResultViewController: UIViewController {
    @IBOutlet weak var topBackground: UIImageView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var releaseDateLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var playerImg: UIImageView!
    @IBOutlet weak var playerTitleLbl: UILabel!
    @IBOutlet weak var playerAuthorLbl: UILabel!
    var lyricsResponse:LyricsResponse?
    var iTunesArray:[ITunes]?
    var song:String!
    var player:AVPlayer?
    var isPlay = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientBackground()
        fetchLyrics(name: song)
        fetchITunes(name: song)
    }
    
    //設定漸層圖片
    func gradientBackground(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = topBackground.bounds
        gradientLayer.colors = [CGColor(red: 85/255, green: 110/255, blue: 170/255, alpha: 1),CGColor(red: 43/255, green: 57/255, blue: 89/255, alpha: 1)]
        topBackground.layer.addSublayer(gradientLayer)
    }
    
    //抓lyricsAPI資料
    func fetchLyrics(name:String){
        //URL encoding
        if let urlStr = "https://some-random-api.ml/lyrics?title=\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            if let url = URL(string: urlStr)
            {
                //利用URLSession抓取JSON資料(data資料、response後台回傳結果、error錯誤)
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data{
                        let decoder = JSONDecoder()
                        do{
                            self.lyricsResponse = try decoder.decode(LyricsResponse.self, from: data)
                            DispatchQueue.main.async {
                                self.updateLyrics()
                            }
                        }catch{
                            print(error)
                        }
                    }
                }.resume()
            }
        }
    }
    
    //抓iTunesAPI資料(發布日期、音樂)
    func fetchITunes(name:String){
        if let urlSTr = "https://itunes.apple.com/search?term=\(name)&media=music".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            if let url = URL(string: urlSTr){
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        do{
                            let iTunesResponse = try decoder.decode(ITunesResponse.self, from: data)
                            self.iTunesArray = iTunesResponse.results
                            let outputFormatter = DateFormatter()
                            outputFormatter.dateFormat = "MMMM d, yyyy"
                            
                            DispatchQueue.main.async {
                                if let date = self.iTunesArray?[0].releaseDate{
                                    let dateStr = outputFormatter.string(from: (date))
                                    self.releaseDateLbl.text = dateStr
                                }
                            }
                        }
                        catch{
                            print(error)
                        }
                    }
                }.resume()
            }
        }
    }
    
    
    //更新lyricsAPI資料的頁面
    func updateLyrics(){
        img.kf.setImage(with: lyricsResponse?.thumbnail.genius)
        titleLbl.text = lyricsResponse?.title
        authorLbl.text = lyricsResponse?.author
        lyricsTextView.text = lyricsResponse?.lyrics
        playerImg.kf.setImage(with: lyricsResponse?.thumbnail.genius)
        playerTitleLbl.text = lyricsResponse?.title
        playerAuthorLbl.text = lyricsResponse?.author
    }

    
    //前往歌詞網頁
    @IBAction func showWeb(_ sender: Any) {
        if let url = lyricsResponse?.links.genius{
            let controller = SFSafariViewController(url: url)
            present(controller, animated: true)
        }
    }
    
    //播放&暫停音樂
    @IBAction func clickPlay(_ sender: UIButton) {
        isPlay.toggle()
        if isPlay == true{
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            if let url = iTunesArray?[0].previewUrl
            {
                player = AVPlayer(url: url)
                player?.play()
            }
        }else{
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player?.pause()
        }
        
        
        
        
        
        
        
    }
    
    
}

//searchBar
extension ResultViewController:UISearchBarDelegate{
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchLyrics(name: searchBar.text ?? "")
        fetchITunes(name: searchBar.text ?? "")
    }
    
}


