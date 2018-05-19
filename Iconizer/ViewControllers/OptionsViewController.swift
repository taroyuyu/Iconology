//
//  OptionsViewController.swift
//  Iconizer
//
//  Created by Liam Rosenfeld on 2/1/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import Cocoa

class OptionsViewController: NSViewController {
    
    // MARK: - Setup
    @IBOutlet weak var presetSelector: NSPopUpButton!
    
    var imageURL: URL?
    var saveDirectory: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presetSelector.removeAllItems()
        if Presets.presets.isEmpty {
            DefaultPresets().addDefaults()
        }
        for preset in Presets.presets {
            print(preset.name)
            presetSelector.addItem(withTitle: preset.name)
        }
        print(imageURL!)
    }
    
    func segue(to: String) {
        if (to == "SavedVC"){
            let savedViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SavedViewController")) as? SavedViewController
            savedViewController?.savedDirectory = saveDirectory!
            view.window?.contentViewController = savedViewController
        }
        else if (to == "DragVC") {
            let dragViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DragViewController")) as? DragViewController
            view.window?.contentViewController = dragViewController
        }
    }
    
    // MARK: - Actions
    @IBAction func convert(_ sender: Any) {
        // Check User Options
        let selectedPreset = presetSelector.indexOfSelectedItem
        
        // Get Image from URL
        let imageToConvert = urlToImage(url: imageURL!)
        
        // Where to save
        let chosenFolder = selectFolder()
        if chosenFolder == "canceled" { return }
        saveDirectory = URL(string: "\(chosenFolder)Icons/")
        print(saveDirectory!)
        createFolder(directory: saveDirectory!)
        
        // Convert and Save
        for (name, size) in Presets.presets[selectedPreset].sizes {
            resize(name: name, image: imageToConvert, w: size[0], h: size[1], saveTo: saveDirectory!)
        }
        
        segue(to: "SavedVC")
        
    }
   
    @IBAction func back(_ sender: Any) {
        segue(to: "DragVC")
    }
    
    
    // MARK: - Convert Between URL, Data, and Image
    func urlToImage(url: URL) -> NSImage {
        do {
            let imageData = try NSData(contentsOf: url, options: NSData.ReadingOptions())
            return NSImage(data: imageData as Data)!
        } catch {
            print("URL to Image Error: \(error)")
        }
        // TODO: - Change the backup return (currently the upload icon)
        return #imageLiteral(resourceName: "uploadIcon")
    }
    
    // MARK: - Save
    func selectFolder() -> String {
        let selectPanel = NSOpenPanel()
        selectPanel.title = "Select a folder to save your icons"
        selectPanel.showsResizeIndicator = true
        selectPanel.canChooseDirectories = true
        selectPanel.canChooseFiles = false
        selectPanel.allowsMultipleSelection = false
        selectPanel.canCreateDirectories = true
        selectPanel.delegate = self as? NSOpenSavePanelDelegate
        
        selectPanel.runModal()
        
        if selectPanel.url != nil {
            return String(describing: selectPanel.url!)
        } else {
            return "canceled"
        }
        
        
    }
    
    func createFolder(directory: URL) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Folder Creation Error: \(error.localizedDescription)")
        }

    }
    
}
