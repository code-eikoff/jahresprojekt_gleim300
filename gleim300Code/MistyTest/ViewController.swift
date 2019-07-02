//  MistyTest
//
//  Created by Jahresprojekt2017/18/19 on 13.02.2019
//  Copyright © 2019 Ivo Max Muellner, Eiko Eickhoff, Gina Schlott
//  All rights reserved

import Cocoa
import AVFoundation


/*
 Main - connects Code and Storybord
 Sets the menus, commandlists and audiosamples.
 Plays sound on command.
 Updates programm, if a command is recoginized or the timer is up.
 */
class ViewController: NSViewController, NSWindowDelegate, NSSpeechRecognizerDelegate, ORSSerialPortDelegate, FileStalkerDelegate{
    
    @IBOutlet var textField: NSTextField!
    @IBOutlet var textFieldExtra: NSTextField!
    
    @IBOutlet var statusBild: NSImageCell!
    @IBOutlet var statusTextCell: NSTextFieldCell!
    
    var speechRecognizer = NSSpeechRecognizer()
    var player = AVAudioPlayer()
    
    var serialPort = ORSSerialPort(path: "/dev/cu.usbmodem1471")
    
    var arduinoConnected = false
    var audioIsPlaying = false
    var isListening = true
    var detectTopics = false
    
    var audioPathPart1 = ""
    var audioPathPart2 = ""
    var audioPathPart3 = ""
    
    var portraits = [[String]]()
    
    var menuCreator = MenuCreator()
    var topLevelMenu = GleimMenu()
    var currentMenu = GleimMenu()
    
    var timer = Timer()
    var timerPause = Timer()
    var timerTopicReset = Timer()
    var tX = Timer()
    let timerInterval = 1.0 //TimeOut und reset auf TopLevelMenu in Sekunden (double)
    let soundDelay = 0.8
    let timerPauseInterval = 900.0 //when nobody said something since 15 min
    let timerTopicInterval = 30.0 //when nobody said a Topic since 30 sec
    
    let stopCommandSerial = "0"
    
//    let fileStalker = FileStalker(timerInterval: 0.05, filename: "/Applications/MAMP/htdocs/Gleimhaus/personen/file.txt")
   
    
    /*
     Gets serialport for the arduino and creates the menu.
     This includes the menu itself, as well as the commandlists.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.window?.delegate = self
        view.layer?.zPosition = .greatestFiniteMagnitude
        view.window?.level = .floating
        
        let spm = ORSSerialPortManager()
        let s = spm.availablePorts
        
        statusAendern(1)
        _ = XmlMenuReader(menuCreator: menuCreator)
        topLevelMenu = menuCreator.getMenu()
        currentMenu = topLevelMenu
        updateSpeechCommands()
        
        for port in s {
            if port.name.contains("usbmodem") {
                serialPort = ORSSerialPort(path: port.path)
                writeToTextExtraWindow("Port-Name: " + port.name)
            }
        }
        serialPort?.delegate=self
        serialPort?.baudRate = 9600
        serialPort?.open()
        
        speechRecognizer?.delegate = self
        speechRecognizer?.blocksOtherRecognizers = false
        speechRecognizer?.listensInForegroundOnly = false
        speechRecognizer?.startListening()  //laesst recognizer auf befehle hoeren
        
        // für die mobile website auf Tablet zum abfragen der Änderungen in datei
//        fileStalker.delegate = self
//        fileStalker.startStalking() //start listening to file and notify when content changed
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown){
            if self.keyDownO(with: $0){
                return nil
            } else {
                return $0
            }
        }
        
        loadPortraits()
        
        //nach 2 sec prüfen ob ardoino angeschlossen ist
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(checkArduino), userInfo: nil, repeats: false)
        
        startTimerForPause()
        playSound(file: "aktiv", ext: "wav")
        
        
    }


    /*
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                                S P R A C H E R K E N N U N G    H A N D L I N G
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
     */
   
    
    /*
     Is called when the speechRecognizer hears a known command.
     Resets timer, changes the menu if needed and calls the functions to play the audio.
     */
    func speechRecognizer(_ sender: NSSpeechRecognizer, didRecognizeCommand command: String) {
        if audioIsPlaying==false{
            for menuElement in currentMenu.getSubMenuList() {
                for elementCommand in menuElement.getOwnCommandList() {
                    if elementCommand == command {
                        
                        // programm pausieren
                        if  isListening == true && menuElement.getName() == "Danke"{
                            isListening = false
                            statusAendern(3)    //Programm pausiert
                            
                            playSound(file:menuElement.getAudioFilePath(), ext:"")  //Pausieren Sound abspielen
                            timerPause.invalidate() //Timer stoppen
                            detectTopics = false
                            
                            sendDataToSP(commandData: stopCommandSerial)
                            writeToTextExtraWindow("lightsOut")
                            
                        //programm aktivieren
                        }else if isListening == false && menuElement.getName() == "sprecht Bilder" {
                            isListening = true
                            if arduinoConnected{
                                statusAendern(2)
                            }else{
                                statusAendern(4)    // Fehlermeldung anzeigen
                                statusTextCell.stringValue = "Fehler, Arduino getrennt"
                            }
                            playSound(file:menuElement.getAudioFilePath(), ext:"")  //Pausieren Sound abspielen
                            
                            detectTopics = false
                            sendDataToSP(commandData: stopCommandSerial)
                            
                            // neuen timer starten
                            timerPause.invalidate()
                            startTimerForPause()
                        
                        // wenn ein name gesagt wird
                        }else if isListening == true && detectTopics == false && !menuElement.isTopic() || isListening == true && detectTopics == true && !menuElement.isTopic(){
                            
                            // das ist nur für debugging/entwicklung
                            writeToTextWindow(command + " --> " + menuElement.getName())
                            
                            // der audiopfad wird vorbereitet mit den teilen vom Namen des Portraits
                            audioPathPart1 = menuElement.getAudioFilePath()
                            audioPathPart3 = menuElement.getName()
                            
                            // das licht hinter dem Bild an machen
                            self.sendDataToSP(commandData: menuElement.getSerialCommand())
                            
                            // der timer für die programmpausierung wird gestartet
                            timerPause.invalidate()
                            startTimerForPause()
                            
                            detectTopics = true
                            startTopicTimer() // nach gewisser zeit geht dadurch das licht wieder aus
                            
                        // wenn ein portrait an ist und ein thema gesagt wird
                        }else if isListening == true && detectTopics == true && menuElement.isTopic(){
                            
                            // das kommando wird im fenster ausgegeben
                            writeToTextWindow("^ " + command + " --> " + menuElement.getName())
                            
                            stopTopicTimer()
                            
                            // der audiopfad wird zusammengesetzt und abgespielt
                            
                            Timer.scheduledTimer(withTimeInterval: soundDelay, repeats: false) { (soundDelay) in
                                self.playSound(file: self.audioPathPart1 + menuElement.getAudioFilePath() + self.audioPathPart3 , ext: "")
                            }
      
                            
                            // der timer wird neu gestartet
                            timerPause.invalidate()
                            startTimerForPause()
                        }
                        
                        if menuElement.getSubMenuCommandList().count != 0{
                            currentMenu = menuElement
                            updateSpeechCommands()
                            print("changed")
                        }
                        return
                    }
                }
            }
        }
    }
    
    
    
    
    /*
     Turn off the light and stop audio
     */
    @objc func Light_Audio_Out(){
        sendDataToSP(commandData: stopCommandSerial)
        if audioIsPlaying {
            player.stop()
        }
        writeToTextExtraWindow("lightsOut")
        audioIsPlaying = false
        detectTopics = false
    }

    
    /*
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                                                A U D I O    S T U F F
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
     */
    
    /*
     stop audio
     */
    @objc func Audio_Out(){
        if audioIsPlaying {
            player.stop()
        }
        audioIsPlaying = false
        startTopicTimer()
    }
    
    /*
     Plays the audio.
     */
    func playSound(file:String, ext:String) -> Void {
        //writeToTextExtraWindow("play file: \""+file+"\"")
        if file == "stop"{
            player.stop()
            resetTimer(1)
        }
        
        let url = URL(fileURLWithPath: NSHomeDirectory()+"/Desktop/Gleim300Assets/soundfiles/"+file+".wav")
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            audioIsPlaying = true
//            resetTimer(player.duration);  licht soll nach thema nicht aus gehen!
            resetTimerAudio(player.duration)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    

    /*
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                            A R D U I N O    &     L I G H T   H A N D L I N G
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
     */
    
    /*
     Turn off the light
     */
    @objc func Light_Out(){
        sendDataToSP(commandData: stopCommandSerial)
        writeToTextExtraWindow("lightsOut")
        startTopicTimer()
    }
    
    
    @objc func checkArduino(){
        if arduinoConnected {
            statusAendern(2)
        } else {
            writeToTextExtraWindow("Arduino getrennt (Port geschlossen)")
            statusAendern(4)
        }
    }
    
    /*
     Sends the data to the serialport and calls the function to reset the timer.
     */
    func sendDataToSP(commandData: String) {
        serialPort?.send(commandData.data(using: .utf8)!)
    }
    
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        writeToTextExtraWindow("Arduino getrennt (Port geschlossen)")
        arduinoConnected = false
        statusAendern(4)
        statusTextCell.stringValue = "Fehler, Arduino getrennt"
    }
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        writeToTextExtraWindow("Arduino verbunden (Port geöffnet)")
        arduinoConnected = true
        statusAendern(2)
    }
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
//        writeToTextWindow("Port: \(data)")
    }
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print(error)
    }
    
    
    /*
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                                        T I M E R    G E S C H I C H T E N
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
     */
    
    
    /*
     Starts a timer, that is needed for going back if the user didn't say anything after a certain time.
     */
    func startTimerForPause(){
        timerPause = Timer.scheduledTimer(timeInterval: timerPauseInterval, target: self, selector: #selector(programPause), userInfo: nil, repeats: false)
    }
    
    @objc func programPause(){
        isListening = false
        writeToTextExtraWindow("Pause")
        statusAendern(3)
        playSound(file: "danke", ext: "wav")
    }
    
    
    /*
     Resets and starts the timer to turn off the light and stop audio.
     */
    func resetTimer(_ duration: Double){
        timer.invalidate()
        startTimer(duration)
    }
    func resetTimerAudio(_ duration: Double){
        timer.invalidate()
        startTimerAudio(duration)
    }
    /*
     Starts a timer, that is needed for pause if the user didn't say anything after a certain time.
     */
    func startTimer(_ duration: Double){
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(Light_Audio_Out), userInfo: nil, repeats: false)
    }
    /*
     Starts a timer, that is needed for pause if the user didn't say anything after a certain time.
     */
    func startTimerAudio(_ duration: Double){
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(Audio_Out), userInfo: nil, repeats: false)
    }
    /*
     Starts a timer, that is needed for going back in the menu structure if the user didn't say anything after a certain time.
     
     */
    func startTopicTimer(){
        stopTopicTimer()
        timerTopicReset = Timer.scheduledTimer(timeInterval: timerTopicInterval, target: self, selector: #selector(Light_Audio_Out), userInfo: nil, repeats: false)
    }
    func stopTopicTimer(){
        timerTopicReset.invalidate()
    }

    
    
    
    
    /*
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                                Ausgabe Fenster - key input - sonstiges
     -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    */
    
    var temp = ""
    /*
     Backup plan in case the audiolistener doesn't work anymore.
     Plays the sound via keyinput.
     This method is only needed for debugging and testing new things.
     */
    func keyDownO(with event: NSEvent) -> Bool{
        if event.keyCode == 53 || event.keyCode == 116 || event.keyCode == 121 || (event.keyCode != 49 && event.keyCode != 36){ //esc Taste
            Audio_Out()
        }

        //leertaste
        if event.keyCode == 49{
            if isListening {
                isListening = false
                statusAendern(3)    //Programm pausiert
                playSound(file:"pause", ext:"wav")  //Pausieren Sound abspielen
                timerPause.invalidate() //Timer stoppen
                detectTopics = false
            } else {
                isListening = true
                if arduinoConnected{
                    statusAendern(2)
                }else{
                    statusAendern(4)    // Fehlermeldung anzeigen
                    statusTextCell.stringValue = "Fehler, Arduino getrennt"
                }
                playSound(file:"aktiv", ext:"wav")
                timerPause.invalidate()
                startTimerForPause()
            }
        }
        
        if event.keyCode == 18 { temp.append("1") }
        if event.keyCode == 19 { temp.append("2") }
        if event.keyCode == 20 { temp.append("3") }
        if event.keyCode == 21 { temp.append("4") }
        if event.keyCode == 23 { temp.append("5") }
        if event.keyCode == 22 { temp.append("6") }
        if event.keyCode == 26 { temp.append("7") }
        if event.keyCode == 28 { temp.append("8") }
        if event.keyCode == 25 { temp.append("9") }
        if event.keyCode == 29 { temp.append("0") }
        if event.keyCode == 36 {
            sendDataToSP(commandData: temp)
            writeToTextExtraWindow("to ardoino: " + temp)
            temp = ""
        }
        

        if event.keyCode == 12 { // q taste zum testen
//            sendDataToSP(commandData: "34")
            
                restartProgram()
           
        }
        
        return true
    }
    
    /*
     writes Text to Window (oben)
     */
    func writeToTextWindow(_ str:String){
        var tempText = textField.stringValue
        tempText.append("\n")
        tempText.append(str)
        textField.stringValue = tempText
    }
    
    /*
     writes Text to extra output Window (unten)
     */
    func writeToTextExtraWindow(_ str:String){
        var tempText = textFieldExtra.stringValue
        tempText.append("\n")
        tempText.append(str)
        textFieldExtra.stringValue = tempText
    }
    
    
    /*
        wenn fehler sind werden sie oben im fenster angezeigt und der punkt ändert die farbe
     */
    func statusAendern(_ int:NSInteger){
        if int==1{
            statusTextCell.stringValue = "Programm wird gestartet"
            statusBild.image = NSImage(named: NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))
        } else if int==2{
            statusTextCell.stringValue = "Programm läuft"
            statusBild.image = NSImage(named: NSImage.Name(rawValue: "NSStatusAvailable"))
        } else if int==3{
            statusTextCell.stringValue = "Programm pausiert"
            statusBild.image = NSImage(named: NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))
        } else {
            statusTextCell.stringValue = "Fehler"
            statusBild.image = NSImage(named: NSImage.Name(rawValue: "NSStatusUnavailable"))
        }
    }

    /*
     läd alle portraits in ein array, wichtig für zufallswiedergabe
     */
    func loadPortraits(){
        // es wird auf das top level verwiesen
        topLevelMenu = menuCreator.getMenu()
        currentMenu = topLevelMenu
        
        // in einem array werden alle namen mit infos gespeichert
        for menuElement in currentMenu.getSubMenuList() {
            if !menuElement.isTopic() && !menuElement.isPause() {
                portraits.append([menuElement.getAudioFilePath(),menuElement.getName(),String(menuElement.getSerialCommand())])
            }
        }
    }
    
    /*
     Calls the function sending the data, if said data was changed.
     Aufruf in FileStalker
     */
    func fileContentChanged(fileSerialCommand serialCommand: String, fileAudio audiofile: String) {
        sendDataToSP(commandData: serialCommand)
        playSound(file: audiofile, ext: "")
    }
    
    /*
     Sets the commands of the currently active menu (or submenu).
     */
    func updateSpeechCommands() {
        var newCommands = currentMenu.getSubMenuCommandList()
        newCommands.append(contentsOf: currentMenu.getReturnCommandList())
        speechRecognizer?.commands=newCommands
    }
    
    func restartProgram(){
        // does nothing
    }
    
    /*
     Closes the app, put out light and audio
     */
    @IBAction func closeApp(_ sender: NSButton) {
        sendDataToSP(commandData: stopCommandSerial)
        exit(0)
    }
    
    func systemStopp() {
        Light_Audio_Out()
        exit(0)
    }

    
}
