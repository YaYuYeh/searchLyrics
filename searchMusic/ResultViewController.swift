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
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var failedBackgroundImg: UIImageView!
    var lyricsResponse:LyricsResponse?
    //宣告空陣列
    var iTunesArray = [ITunes]()
    var song:String!
    var player:AVPlayer?
    var isPlay = false
    //宣告iTunes正確資料的索引值
    var index = 0
    var indexIsFound = false

    

    override func viewDidLoad() {
        super.viewDidLoad()
        backAction()
        gradientBackground()
        fetchLyrics(name: song)
        fetchITunes(name: song)
//        DispatchQueue.main.async {
        sleep(5)
        checkInfo()
        musicEnd()
    }
    
    
    func backAction(){
        navigationItem.backAction = UIAction(handler: { _ in
            self.player?.pause()
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func checkInfo(){
        //迴圈判斷iTunes歌手是否與lyrics歌手相同，來確認是否為同一首歌
        print("開始比對資料")
        if iTunesArray.isEmpty == false{
            for i in 0...(iTunesArray.count-1){
                print("找到的index\(index)")
                if iTunesArray[i].trackName != "",
                   iTunesArray[i].artistName == lyricsResponse!.author{
                       index = i
                       indexIsFound = true

                       failedBackgroundImg.isHidden = true
                       break
                }
            }
            if indexIsFound == false{
                print("找不到index")
                DispatchQueue.main.async {
                    self.searchIssue()
                }
            }
        }else{
            print("iTunes是空陣列")
            DispatchQueue.main.async {
                self.searchIssue()
            }
        }
    }

    
    
    //比對完成後若沒有相符的資料，跳alert並回到搜尋頁面
    func searchIssue(){
        print("搜尋結果有問題，跳回上一頁")
            let alertCV = UIAlertController(title: "Not Found", message: "Return to the previous page.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _
                in
                self.navigationController?.popViewController(animated: true)
            }
            alertCV.addAction(okAction)
            present(alertCV, animated: true)
    }
    
    
    //音樂停止時
    func musicEnd(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
            print("歌曲播放完畢")
            self.playerButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.isPlay = false
        }
    }
    
    
    
    //設定漸層圖片
    func gradientBackground(){
        //建立顯示漸層顏色的CAGradientLayer物件
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = topBackground.bounds
        let startColor = CGColor(red: 85/255, green: 110/255, blue: 170/255, alpha: 1)
        let endColor = CGColor(red: 43/255, green: 57/255, blue: 89/255, alpha: 1)
        gradientLayer.colors = [startColor, endColor]
        topBackground.layer.addSublayer(gradientLayer)
    }
    
    //抓lyricsAPI資料
    func fetchLyrics(name:String){
        //URL encoding
        if let urlStr = "https://some-random-api.ml/lyrics?title=\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            if let url = URL(string: urlStr)
            {
                //利用URLSession抓取JSON資料(data資料、response後台回傳結果、error錯誤)
                URLSession.shared.dataTask(with: url) {
                    data, response, error
                    in
                    if let data{
                        let decoder = JSONDecoder()
                        do{
                            self.lyricsResponse = try decoder.decode(LyricsResponse.self, from: data)
                            DispatchQueue.main.async {
                                //更新lyricsAPI資料UI
                                self.updateLyrics()
                            }
                            print("歌詞抓完了:\(String(describing: self.lyricsResponse))")
                            //self.fetchITunes(name: self.song)
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
                URLSession.shared.dataTask(with: url) {
                    data, response, error
                    in
                    if let data{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        do{
                            let iTunesResponse = try decoder.decode(ITunesResponse.self, from: data)
                            self.iTunesArray = iTunesResponse.results

                            
                            print("iTunes抓完了\(self.iTunesArray)")
//                            sleep(5)
//                            self.checkInfo()

                            
                            let outputFormatter = DateFormatter()
                            //設定時間顯示的格式
                            outputFormatter.dateFormat = "MMMM d, yyyy"
                            print("bbb")
                            //searchIssue()
                            
                            
                            
                            DispatchQueue.main.async {
                                if self.iTunesArray.isEmpty == false {
                                    let date = self.iTunesArray[self.index].releaseDate
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
    
    
    //更新lyricsAPI資料UI
    func updateLyrics(){
        img.kf.setImage(with: lyricsResponse?.thumbnail?.genius)
        titleLbl.text = lyricsResponse?.title?.capitalized
        authorLbl.text = lyricsResponse?.author
        lyricsTextView.text = lyricsResponse?.lyrics
        playerImg.kf.setImage(with: lyricsResponse?.thumbnail?.genius)
        playerTitleLbl.text = lyricsResponse?.title?.capitalized
        playerAuthorLbl.text = lyricsResponse?.author
    }

    
    //前往歌詞網頁
    @IBAction func showWeb(_ sender: Any) {
        if let url = lyricsResponse?.links?.genius{
            let controller = SFSafariViewController(url: url)
            present(controller, animated: true)
        }
    }
    
    //播放&暫停音樂
    @IBAction func clickPlay(_ sender: UIButton) {
        isPlay.toggle()
        if isPlay == true{
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            //searchIssue()
            let url = iTunesArray[index].previewUrl
            player = AVPlayer(url: url)
            player?.play()
        }else{
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player?.pause()
        }
    }
}

