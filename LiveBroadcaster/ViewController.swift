//
//  ViewController.swift
//  LiveBroadcaster
//
//  Created by Abd on 9/28/18.
//  Copyright © 2018 Abdulmajeed. All rights reserved.
//

import UIKit
import WowzaGoCoderSDK

class ViewController: UIViewController, WOWZStatusCallback {

    @IBOutlet weak var broadcastButton: UIButton!
    var goCoder: WowzaGoCoder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let goCoderLicensingError = WowzaGoCoder.registerLicenseKey("GOSK-8C45-010C-ED16-9E86-0FA7")
        if goCoderLicensingError != nil {
            print(goCoderLicensingError!.localizedDescription)
        } else {
            // Initialize the GoCoder SDK
            self.goCoder = WowzaGoCoder.sharedInstance()
        }
        if self.goCoder != nil {
            // Associate the U/I view with the SDK camera preview
            self.goCoder.cameraView = self.view;
            
            // Start the camera preview
            self.goCoder.cameraPreview?.start()
            
            // Get a copy of the active config
            let goCoderBroadcastConfig: WowzaConfig = self.goCoder.config
            
            // Set the defaults for 720p video
            goCoderBroadcastConfig.load(WOWZFrameSizePreset.preset1280x720)
            
            // Set the connection properties for the target Wowza Streaming Engine server or Wowza Streaming Cloud live stream
            goCoderBroadcastConfig.hostAddress = "52.53.240.158"
            goCoderBroadcastConfig.portNumber = 1935
            goCoderBroadcastConfig.applicationName = "app-0f2b"
            goCoderBroadcastConfig.streamName = "a8a38c49"
            
            // Update the active config
            self.goCoder.config = goCoderBroadcastConfig
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onWOWZStatus(_ status: WOWZStatus!) {
        var statusMessage: String? = nil
        switch status.state {
        case .idle:
            statusMessage = "The broadcast is stopped"
            break
        case .starting:
            statusMessage = "Broadcast initialization"
            break
        case .running:
            statusMessage = "Streaming is active"
            break
        case .stopping:
            statusMessage = "Broadcast shutting down"
            break
        case .buffering:
            break
        case .ready:
            break
        }
        if statusMessage != nil {
            print("Broadcast status: \(statusMessage!)")
        }
    }
    
    func onWOWZError(_ status: WOWZStatus!) {
        // If an error is reported by the GoCoder SDK, display an alert
        // that contains the error details using the U/I thread
        print(status.description)
        DispatchQueue.main.async {
            let alertDialog = UIAlertController(title: "Streaming Error", message: status.description, preferredStyle:.alert)
            alertDialog.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertDialog, animated: true, completion: nil)
        }
            
    }
    
    @IBAction func broadcastButtonTapped(_ sender: UIButton) {
        // Ensure the minimum set of configuration settings have been specified necessary to
        // initiate a broadcast streaming session
        let configValidationError = self.goCoder.config.validateForBroadcast()
        
        if configValidationError != nil {
            let alertDialog = UIAlertController(title: "Incomplete Streaming Settings", message: self.goCoder.status.description, preferredStyle:.alert)
            alertDialog.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            alertDialog.show(self, sender: nil)
        } else if self.goCoder.status.state != WOWZState.running {
            // Start streaming
            self.goCoder.startStreaming(self)
            print(self.goCoder.status.state.rawValue)
        } else {
            // Stop the broadcast that is currently running
            self.goCoder.endStreaming(self)
        }
    }

}

