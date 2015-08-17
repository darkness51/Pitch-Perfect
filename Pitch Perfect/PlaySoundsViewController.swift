//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Carlos Aguilar on 15/8/15.
//  Copyright (c) 2015 Carlos Aguilar. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    // Initialize global variables
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()
    var audioPlayer2:AVAudioPlayer = AVAudioPlayer()
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer2 = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        // Enabling rate give us the posibility to change rate in the next functions
        audioPlayer.enableRate = true
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudio(0.5)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        playAudio(1.5)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        stopPlayerAndEngine()
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playReverbAudio(sender: UIButton) {
        playAudioWithReverb()
    }
    
    
    @IBAction func playEchoAudio(sender: UIButton) {
        // Stop and reset the audio player and audio engine
        stopPlayerAndEngine()
        
        // Code sample from here: http://sandmemory.blogspot.com/2014/12/how-would-you-add-reverbecho-to-audio.html
        let delay:NSTimeInterval = 0.1  //100ms
        var playtime:NSTimeInterval
        playtime = audioPlayer2.deviceCurrentTime + delay
        audioPlayer2.stop()
        audioPlayer2.currentTime = 0
        audioPlayer2.volume = 0.8;
        audioPlayer2.playAtTime(playtime)
    }
    
    func stopPlayerAndEngine()
    {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playAudio(speed:Float) {
        stopPlayerAndEngine()
        audioPlayer.rate = speed
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    func playAudioWithVariablePitch(pitch:Float) {
        // Stop and reset the audio player and audio engine
        stopPlayerAndEngine()
        // Creating an audio player node
        var audioPlayerNode = AVAudioPlayerNode()
        // Attaching the node to the audio engine
        audioEngine.attachNode(audioPlayerNode)
        
        // Change the pitch and attaching to audio engine
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        // Connecting the audio player node and the pitch speed
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        // Playing the file
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    func playAudioWithReverb() {
        // Stop and reset the audio player and audio engine
        stopPlayerAndEngine()
        // Creating an audio player node
        var audioPlayerNode = AVAudioPlayerNode()
        
        // Create the effect
        // Sample code from here: http://objective-audio.jp/2014/09/avaudioengine.html
        // Second code sample here: http://www.robotlovesyou.com/mixing-between-effects-with-avfoundation/
        let unitReverb = AVAudioUnitReverb()
        unitReverb.loadFactoryPreset(AVAudioUnitReverbPreset.LargeHall)
        unitReverb.wetDryMix = 60.0
        
        // Attaching the node to the audio engine
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(unitReverb)
        
        // Connecting the audio player node and the pitch speed
        audioEngine.connect(audioPlayerNode, to: unitReverb, format: audioFile.processingFormat)
        audioEngine.connect(unitReverb, to: audioEngine.outputNode, format: audioFile.processingFormat)
        
        // Playing the file
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()

    }
    
}
