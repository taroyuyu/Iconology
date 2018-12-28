//
//  SelectPresetViewController.swift
//  Iconology
//
//  Created by Liam Rosenfeld on 5/19/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import Cocoa

class SelectPresetViewController: NSViewController {
    
    @IBOutlet weak var presetTable: NSTableView!
    @IBOutlet weak var manageRowsButton: NSSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presetTable.delegate = self
        presetTable.dataSource = self
    }
    
    // MARK: - Actions
    @IBAction func next(_ sender: Any) {
        forceSaveText()
        let presetSelected = presetTable.selectedRow
        if presetSelected >= 0 {
            print(UserPresets.presets[presetSelected].name)
            
            let editPresetViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("EditPresetViewController")) as? EditPresetViewController
            editPresetViewController?.presetSelected = presetSelected
            view.window?.contentViewController = editPresetViewController
        }
    }
    
    @IBAction func apply(_ sender: Any) {
        forceSaveText()
        UserPresets.savePresets()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PresetApply"), object: nil)
    }
    
    @IBAction func manageRows(_ sender: Any) {
        if manageRowsButton.selectedSegment == 0 {
            newRow()
        } else if manageRowsButton.selectedSegment == 1 {
            removeRow()
        }
    }
    
    
    // MARK: - Table Updates
    func newRow() {
        // Generate Name
        var name = "New Preset"
        var n = 1
        while true {
            var state = "good"
            for preset in UserPresets.presets {
                if name == preset.name {
                    state = "fail"
                }
            }
            if state != "fail" {
                break
            }
            name = "New Preset \(n)"
            n += 1
        }
        
        // Update Data
        UserPresets.addPreset(name: name, sizes: [ImgSetPreset.ImgSetSize](), usePrefix: false)
        
        // Update Table
        presetTable.insertRows(at: IndexSet(integer: UserPresets.presets.count-1), withAnimation: .effectFade)
        presetTable.selectRowIndexes(IndexSet(integer: UserPresets.presets.count-1), byExtendingSelection: false)
    }
    
    func removeRow() {
        let selectedRow = presetTable!.selectedRow
        if selectedRow != -1 {
            // Update Data
            UserPresets.presets.remove(at: selectedRow)
        
            // Update Table
            presetTable.removeRows(at: IndexSet(integer: selectedRow), withAnimation: .effectFade)
            if selectedRow > UserPresets.presets.count - 1{
                presetTable.selectRowIndexes(IndexSet(integer: selectedRow-1), byExtendingSelection: false)
            } else {
                presetTable.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
            }
        }
    }
    
    // MARK: - Textbox Management
    func forceSaveText() {
        let selectedColumn = presetTable.selectedColumn
        let selectedRow = presetTable.selectedRow
        if selectedRow != -1 {
            let selected = presetTable.view(atColumn: selectedColumn, row: selectedRow, makeIfNecessary: false) as! NSTableCellView
            textFieldFinishEdit(sender: selected.textField!)
        }
    }
    
    @IBAction func textFieldFinishEdit(sender: NSTextField) {
        let selectedRow = presetTable.selectedRow
        let value = sender.stringValue
        
        // Check Not Duplicate        
        for index in 0..<UserPresets.presets.count {
            if value == UserPresets.presets[index].name && index != selectedRow {
                sender.stringValue = UserPresets.presets[selectedRow].name
                Alerts.warningPopup(title: "Name Already Exists", text: "'\(sender.stringValue)' is Already Taken")
                print("WARN: Name Already Exists")
                return
            }
        }
        
        if selectedRow != -1 {
            UserPresets.presets[selectedRow].name = value
        }
    }
}

// MARK: - Table Setup
extension SelectPresetViewController: NSTableViewDataSource {
    
    func numberOfRows(in presetList: NSTableView) -> Int {
        return UserPresets.presets.count
    }
    
}

extension SelectPresetViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = UserPresets.presets[row]
        let text = item.name

        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "selectTextCell"), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = text
        return cell
    }
    
}