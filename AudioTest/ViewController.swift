//
//  ViewController.swift
//  AudioTest
//
//  Created by Murawaki on 2017/12/11.
//  Copyright © 2017年 Murawaki. All rights reserved.
//

import UIKit

import AudioKit
import AudioKitUI

class ViewController: UIViewController {

    var oscillator1 = AKOscillator()
    var oscillator2 = AKOscillator()
    var mixer = AKMixer()
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var plot: EZAudioPlot!
    @IBOutlet weak var micLabel: UILabel!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        // Do any additional setup after loading the view, typically from a nib.
        
        mixer = AKMixer(oscillator1, oscillator2)
        
        // Cut the volume in half since we have two oscillators
        mixer.volume = 0.8
        AudioKit.output = mixer
        AudioKit.start()
        
        slider.addTarget(self, action: #selector(self.sliderChanged(slider:)), for: .valueChanged)
        
        frequencyLabel.text = "\(slider.value) hz"
    }
    
    func setupPlot() {
        let plo = AKNodeOutputPlot(mic, frame: plot.bounds)
        plo.plotType = .buffer
        // plo.shouldFill = true
        plo.shouldMirror = true
        plo.color = UIColor.blue
        plot.addSubview(plo)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        AudioKit.start()
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(self.updateUI),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc func sliderChanged(slider: UISlider) {
        frequencyLabel.text = "\(slider.value) hz"
        
        if oscillator1.isPlaying {
            oscillator1.stop()
            oscillator2.stop()
            oscillator1.frequency = Double(slider.value)
            oscillator1.start()
            oscillator2.frequency = Double(slider.value)
            oscillator2.start()
        }
    }
    
    @IBAction func toggleButton(_ sender: UIButton) {
        toggleSound()
    }
    
    private func toggleSound() {
        if oscillator1.isPlaying {
            oscillator1.stop()
            oscillator2.stop()
        } else {
            oscillator1.frequency = Double(slider.value)
            oscillator1.start()
            oscillator2.frequency = Double(slider.value)
            oscillator2.start()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func updateUI() {
        micLabel.text = String(format: "%0.1f", tracker.frequency)
        
        if tracker.amplitude > 0.1 {

            /*
            var frequency = Float(tracker.frequency)
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }*/
            
            /*
            var minDistance: Float = 10_000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
            let octave = Int(log2f(Float(tracker.frequency) / frequency))
            noteNameWithSharpsLabel.text = "\(noteNamesWithSharps[index])\(octave)"
            noteNameWithFlatsLabel.text = "\(noteNamesWithFlats[index])\(octave)"
            */
        }
        //amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }

}

