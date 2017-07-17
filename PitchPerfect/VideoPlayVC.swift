//
//  VideoPlayVC.swift
//  PitchPerfect
//
//  Created by xp on 2017/3/2.
//  Copyright © 2017年 com.yunwangnet. All rights reserved.
//

import UIKit
import AVFoundation

enum ButtonType: Int {
    case slow = 0, fast, chipmunk, vader, echo, reverb
}

class VideoPlayVC: UIViewController ,AVAudioPlayerDelegate{
    
    
    var audioPlayer : AVAudioPlayer!
    var videoPlayH : VideoPlayHelper!
    
    
    //所有播放按钮的响应函数
    @IBAction func allButsAction(_ sender: UIButton) {
        switch ButtonType(rawValue: sender.tag)! {
        case .slow:
            videoPlayH.palyVideo(rate: 0.5)
            break
        case .fast:
            videoPlayH.palyVideo(rate: 1.5)
            break
        case .chipmunk:
            videoPlayH.palyVideo(pitch: 1000)
            break
        case .vader:
            videoPlayH.palyVideo(pitch: -1000)
            break
        case .echo:
            videoPlayH.palyVideo(echo: true)
            break
        case .reverb:
            videoPlayH.palyVideo(reverb: true)
            break
//        default:
//            playVideo()
//            break
        }
        
        
    }
    
    
    //停止按钮
    @IBAction func stopBtnAction(_ sender: UIButton) {
        videoPlayH.stopAudio()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "播放"
        
//        HomeVC.Variables.videoName
        print(HomeVC.Variables.videoName)
        
        videoPlayH = VideoPlayHelper()
        videoPlayH.aVC = self
        videoPlayH.setUpAudioFile(url: URL(fileURLWithPath: HomeVC.Variables.videoPath))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        configureUI(.notPlaying)
//    }
    
    // MARK: -  按钮响应函数
    
    // MARK: -  网络请求
    
    // MARK: -  协议函数
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    // MARK: -  组装数据、创建视图、自定义方法
    func playVideo() {
        if audioPlayer == nil {
            let url = URL.init(fileURLWithPath: HomeVC.Variables.videoPath)
            do {
                try audioPlayer = AVAudioPlayer.init(contentsOf: url)
                audioPlayer.numberOfLoops = 0
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
            } catch  {
                
            }
        }else{
            if !audioPlayer.isPlaying {
                let url = URL.init(fileURLWithPath: HomeVC.Variables.videoPath)
                do {
                    try audioPlayer = AVAudioPlayer.init(contentsOf: url)
                    audioPlayer.numberOfLoops = 0
                    audioPlayer.delegate = self
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                    
                } catch  {
                    
                }
                
            }else{
                audioPlayer.stop()
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
