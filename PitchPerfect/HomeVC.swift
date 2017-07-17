//
//  HomeVC.swift
//  PitchPerfect
//
//  Created by xp on 2017/3/2.
//  Copyright © 2017年 com.yunwangnet. All rights reserved.
//


//  后面将录音独立成一个类来调用
//  现在是这边录音后跳转到另外一个VC播放，后面改成 先跳转到一个列表VC选择播放那段音频


import UIKit

import AVFoundation

let statusRecording = "正在录音中..."
let statusRecorded = "点击录音"

class HomeVC: UIViewController ,AVAudioRecorderDelegate {
    //全局变量 var无需赋值 let必须赋值
    var statusLabel : UILabel?
    //🇨🇳懒加载有两种调用方式：1.只使用闭包的方式，这种方式没有延迟调用的特性，在持有它的对象初始化的时候就会调用，就像上面的代码；2.带有Lazy关键字修饰的闭包方式，这种只有在使用的时候才会调用，Lazy是延迟调用关键字。
    //懒加载录音器
    var audioRecorder : AVAudioRecorder!
//        = { () -> AVAudioRecorder in
//    }()
    
    //类的常量、变量声明   在其他类中使用 Home.Constants/Variables.xxx调用
    struct Constants {
        static let name = "MyClass"
    }
    struct Variables {
        static var videoName = ""
        static var videoPath = ""
    }
    
    @IBOutlet weak var recordImageView: UIImageView!
    
    //🇨🇳在函数的入参前加 _ 代表着在调用时可以直接省略参数名称。如：有_ recordBtnAction(按钮对象)  无_ recordBtnAction(sender:按钮对象)
    //录音按钮
    @IBAction func recordBtnAction(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "录音"
        
        self.setUpRecord()
        
        let longTop = UILongPressGestureRecognizer(target: self, action: #selector(HomeVC.longGesAction))
        recordImageView.addGestureRecognizer(longTop)
        
//        let videoPVC = VideoPlayVC()
//        
//        
//        self.navigationController?.pushViewController(videoPVC, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -  按钮响应函数
    //长按响应函数
    func longGesAction(longGes:UILongPressGestureRecognizer) -> Void {
        switch longGes.state {
        case .began:
            NSLog("录音开始")
            if self.canRecord() {
                audioRecorder.record()
            }
            
            break
        case .changed:
            NSLog("录音中")
            
            break
        case .ended , .cancelled:
            NSLog("录音结束或取消")
            audioRecorder.stop()
            
            break
        case .failed:
            NSLog("录音失败")
            
            break
            
        default:
            break
            
        }
    }
    
    // MARK: -  网络请求
    
    // MARK: -  协议函数
    
    // MARK: -  组装数据、创建视图、自定义方法
    //初始化录音器
    func setUpRecord() -> Void {
        //创建录音文件保存路径
        let url = self.getSavePath()
        //创建录音格式设置
        let settingDic = self.getAudioSetting()
        //创建录音机
        do{
            try audioRecorder = AVAudioRecorder(url: url, settings: settingDic)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            print("成功初始化")
        }
        catch{
            print("初始化失败")
        }
    }
    
    //获取录音权限. 返回值,YES为无拒绝,NO为拒绝录音.
    func canRecord() -> Bool {
        var canR = false
        if (UIDevice.current.systemVersion as NSString).floatValue >= 7.0 {
            let audioSession = AVAudioSession.sharedInstance()
            if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
                AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                    
                    canR = granted
                    if granted {
                        print("granted")
                    } else{
                        print("not granted")
                    }
                })
                
            }
        }else{
            canR = true
        }
        
        return canR
    }
    
    /**
     *  取得录音文件保存路径
     *
     *  @return 录音文件路径
     */
    func getSavePath() -> URL {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let str = formatter.string(from: Date())
        let fileNme = str + ".aac"
        HomeVC.Variables.videoName = fileNme
        
        let urlStr = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        
        let url = URL.init(fileURLWithPath: urlStr + "/" + fileNme)
        print(url.absoluteString)
        
        HomeVC.Variables.videoPath = urlStr + "/" + fileNme
        
        return url
    }
    
    func getAudioSetting() -> Dictionary<String, Any> {
        
        let recDic = [AVEncoderAudioQualityKey:NSNumber(value:AVAudioQuality.low.rawValue),
//                      AVEncoderBitRateKey:NSNumber(value:16), //这句话加上就录制不成功 不清楚为什么
                      AVNumberOfChannelsKey:NSNumber(value:2),
                      AVSampleRateKey:NSNumber(value:44100.0),
                      AVFormatIDKey:NSNumber(value:kAudioFormatMPEG4AAC) ] as [String : Any]  //录音质量：low；每个采样点位数,分为8、16、24、32； 频道类型：双声道，1为单声道；录音采样率：随意设置，一般为8000； , AVFormatIDKey:kAudioFormatMPEG4AAC 录音格式：AAC格式
        
        return recDic
    }
    

}

