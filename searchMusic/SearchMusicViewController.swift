//
//  SearchMusicViewController.swift
//  searchMusic
//
//  Created by Ya Yu Yeh on 2022/9/18.
//

import UIKit

class SearchMusicViewController: UIViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //透過判斷來控制segue是否可使用:此例searchBar若為nil，則不能使用
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if let _ = searchBar.text {   此為判斷是否為nil
//        if searchBar.text != nil{
//            return true
//        }
//        return false
//
//        if searchBar.text?.isEmpty == false{  //此為判斷是否為空
//            return true
//        }
//        return false
//
//        if searchBar.text != ""{
//            return true
//        }
//        return false
//    }
    
    
    
    @IBSegueAction func passInfo(_ coder: NSCoder) -> ResultViewController? {
        let resultVC = ResultViewController(coder: coder)
        resultVC?.song = searchBar.text
        return resultVC
    }
    
}
    
extension SearchMusicViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != ""{
            performSegue(withIdentifier: "ResultViewController", sender: nil)
        }
        view.endEditing(true)
    }
}
