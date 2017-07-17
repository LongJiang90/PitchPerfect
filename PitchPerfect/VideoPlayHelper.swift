//
//  VideoPlayHelper.swift
//  PitchPerfect
//
//  Created by xp on 2017/3/7.
//  Copyright © 2017年 com.yunwangnet. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayHelper: NSObject ,AVAudioPlayerDelegate {
    
    var aVC : UIViewController!
    var recordedAudioURL : URL!
    var audioFile : AVAudioFile!
    var audioEngine : AVAudioEngine!
    var audioPlayerNode : AVAudioPlayerNode!
    var stopTimer : Timer!
    
    // MARK: Alerts
    struct Alerts {
        static let DismissAlert = "Dismiss/取消"
        static let RecordingDisabledTitle = "Recording Disabled/无法录音"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings./你没有权限使用麦克风，去设置"
        static let RecordingFailedTitle = "Recording Failed/录音失败"
        static let RecordingFailedMessage = "Something went wrong with your recording./你的录音有问题"
        static let AudioRecorderError = "Audio Recorder Error/音频录音器错误"
        static let AudioSessionError = "Audio Session Error/音频会话错误"
        static let AudioRecordingError = "Audio Recording Error/音频记录错误"
        static let AudioFileError = "Audio File Error/音频文件错误"
        static let AudioEngineError = "Audio Engine Error/音频引擎错误"
    }
    
    enum playState {
        case playing, notPlay
    }
    
    func setUpAudioFile(url:URL) {
        do {
            try audioFile = AVAudioFile(forReading: url)
            
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    func palyVideo(rate:Float? = nil, pitch:Float? = nil, echo:Bool = false, reverb:Bool = false) {
        
        if audioFile == nil {
            showAlert("音频文件为空，请返回录音", message: String(""))
            return
        }
        
        //初始化音频引擎 init audio engine components
        audioEngine = AVAudioEngine()
        
        //初始化播放节点并加入引擎中 init player node, add to engine
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        //调整节点的速率/节距 node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if rate != nil {
            changeRatePitchNode.rate = rate!
        }
        if pitch != nil {
            changeRatePitchNode.pitch = pitch!
        }
        audioEngine.attach(changeRatePitchNode)
        
        //回声 node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        //混响 node for reverb
        let revrebNode = AVAudioUnitReverb()
        revrebNode.loadFactoryPreset(.cathedral)
        revrebNode.wetDryMix = 50
        audioEngine.attach(revrebNode)
        
        //链接所有节点 connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode,changeRatePitchNode,echoNode,revrebNode,audioEngine.outputNode)
        }else if echo == true {
            connectAudioNodes(audioPlayerNode,changeRatePitchNode,echoNode,audioEngine.outputNode)
        }else if reverb == true {
            connectAudioNodes(audioPlayerNode,changeRatePitchNode,revrebNode,audioEngine.outputNode)
        }else {
            connectAudioNodes(audioPlayerNode,changeRatePitchNode,audioEngine.outputNode)
        }
        
        //启动引擎 schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) { 
            var delayInSeconds :Double = 0.0 //延迟秒数
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                if rate != nil {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime)/Double(self.audioFile.processingFormat.sampleRate)/Double(rate!)
                }else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime)/Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            //组装一个定时器在播放完成时调用stopAudio schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(VideoPlayHelper.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer, forMode: RunLoopMode.defaultRunLoopMode)
        }
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        audioPlayerNode.play()
        
    }
    
    func stopAudio() {
        if audioPlayerNode != nil {
            audioPlayerNode.stop()
        }
        
        if stopTimer != nil {
            stopTimer.invalidate()
        }
        
        if audioEngine != nil {
            audioEngine.stop()
            audioEngine.reset()
        }
        
    }
    
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        aVC.present(alert, animated: true, completion: nil)
    }
}
