//
//  ViewController.swift
//  HomeWork_iOS
//
//  Created by Adir Davidov on 08/06/2025.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var insertNameTextField: UITextField!
    @IBOutlet weak var hiUserLabel: UILabel!
    @IBOutlet weak var westSideImageView: UIImageView!
    @IBOutlet weak var eastSideImageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private let locationManager = CLLocationManager()
    private let referenceLocation = CLLocation(latitude: 32.0853, longitude: 34.7818)
    private var userSide: String = ""
    private var hasLocationBeenDetermined = false
    private let userNameKey = "SavedUserName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraintsForIBOutlets()
        setupLocationManager()
        loadSavedUserName()
        
        let hasLocationFromUserDefaults = UserDefaults.standard.bool(forKey: "HasLocationDetermined")
        let savedSide = UserDefaults.standard.string(forKey: "UserSide") ?? ""
        
        if hasLocationFromUserDefaults && !savedSide.isEmpty {
            hasLocationBeenDetermined = true
            userSide = savedSide
            
            DispatchQueue.main.async {
                let name = self.insertNameTextField.text ?? "User"
                self.showSavedLocationResult(side: savedSide, name: name)
            }
        } else if !hasLocationBeenDetermined {
            startLocationCheck()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gameFinished),
            name: NSNotification.Name("GameFinished"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateImagesForCurrentMode),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func gameFinished() {
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        insertNameTextField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
    }
    
    private func setupConstraintsForIBOutlets() {
        insertNameTextField.translatesAutoresizingMaskIntoConstraints = false
        hiUserLabel.translatesAutoresizingMaskIntoConstraints = false
        westSideImageView.translatesAutoresizingMaskIntoConstraints = false
        eastSideImageView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        setupPortraitConstraints()
        setupLandscapeConstraints()
        
        NSLayoutConstraint.activate(portraitConstraints)
        setupElementStyles()
    }
    
    private func setupPortraitConstraints() {
        portraitConstraints = [
            hiUserLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            hiUserLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hiUserLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            insertNameTextField.topAnchor.constraint(equalTo: hiUserLabel.bottomAnchor, constant: 20),
            insertNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            insertNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            insertNameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            westSideImageView.topAnchor.constraint(equalTo: insertNameTextField.bottomAnchor, constant: 30),
            westSideImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            westSideImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            westSideImageView.heightAnchor.constraint(equalToConstant: 250),
            
            eastSideImageView.topAnchor.constraint(equalTo: insertNameTextField.bottomAnchor, constant: 30),
            eastSideImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eastSideImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            eastSideImageView.heightAnchor.constraint(equalTo: westSideImageView.heightAnchor),
            
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.topAnchor.constraint(greaterThanOrEqualTo: westSideImageView.bottomAnchor, constant: 30),
        ]
    }
    
    private func setupLandscapeConstraints() {
        landscapeConstraints = [
            hiUserLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            hiUserLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hiUserLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            insertNameTextField.topAnchor.constraint(equalTo: hiUserLabel.bottomAnchor, constant: 10),
            insertNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            insertNameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            insertNameTextField.heightAnchor.constraint(equalToConstant: 36),
            
            westSideImageView.topAnchor.constraint(equalTo: insertNameTextField.bottomAnchor, constant: 15),
            westSideImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            westSideImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            westSideImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            eastSideImageView.topAnchor.constraint(equalTo: insertNameTextField.bottomAnchor, constant: 15),
            eastSideImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            eastSideImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            eastSideImageView.heightAnchor.constraint(equalTo: westSideImageView.heightAnchor),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            startButton.heightAnchor.constraint(equalToConstant: 40)
        ]
    }
    
    private func setupElementStyles() {
        startButton.layer.cornerRadius = 8
        startButton.backgroundColor = UIColor.systemGray
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        startButton.setTitle("Getting Location...", for: .normal)
        startButton.isEnabled = false
        
        hiUserLabel.textAlignment = .center
        hiUserLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        hiUserLabel.numberOfLines = 0
        
        insertNameTextField.borderStyle = .roundedRect
        insertNameTextField.placeholder = "Insert Name"
        insertNameTextField.textAlignment = .center
        insertNameTextField.autocorrectionType = .no
        insertNameTextField.spellCheckingType = .no
        insertNameTextField.delegate = self
        insertNameTextField.font = UIFont.systemFont(ofSize: 16)
        
        westSideImageView.contentMode = .scaleAspectFit
        eastSideImageView.contentMode = .scaleAspectFit
        updateImagesForCurrentMode()
        
        startButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        startButtonTapped(startButton)
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard !GameViewController.isActive else {
            showAlert(title: "Game Already Running", message: "A game is already in progress!")
            return
        }
        
        guard let name = insertNameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter your name first")
            return
        }
        
        saveUserName(name)
        performSegue(withIdentifier: "goToGameScreen", sender: self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            let isLandscape = size.width > size.height
            
            NSLayoutConstraint.deactivate(self.portraitConstraints)
            NSLayoutConstraint.deactivate(self.landscapeConstraints)
            
            if isLandscape {
                NSLayoutConstraint.activate(self.landscapeConstraints)
                
                self.hiUserLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                self.insertNameTextField.font = UIFont.systemFont(ofSize: 12)
                self.startButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                
            } else {
                NSLayoutConstraint.activate(self.portraitConstraints)
                
                self.hiUserLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                self.insertNameTextField.font = UIFont.systemFont(ofSize: 16)
                self.startButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            }
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    private func loadSavedUserName() {
        let savedName = UserDefaults.standard.string(forKey: userNameKey)
        
        if let name = savedName, !name.isEmpty {
            insertNameTextField.text = name
            hiUserLabel.text = "Hi \(name)"
        } else {
            hiUserLabel.text = "Hi User"
        }
    }
    
    private func saveUserName(_ name: String) {
        UserDefaults.standard.set(name, forKey: userNameKey)
        UserDefaults.standard.synchronize()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    @objc private func nameTextFieldChanged() {
        guard let name = insertNameTextField.text, !name.isEmpty else {
            return
        }
        saveUserName(name)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        
        if let name = insertNameTextField.text, !name.isEmpty {
            saveUserName(name)
        }
    }
    
    private func startLocationCheck() {
        let hasLocationFromUserDefaults = UserDefaults.standard.bool(forKey: "HasLocationDetermined")
        let savedSide = UserDefaults.standard.string(forKey: "UserSide") ?? ""
        
        if hasLocationFromUserDefaults && !savedSide.isEmpty {
            hasLocationBeenDetermined = true
            userSide = savedSide
            
            let name = insertNameTextField.text ?? "User"
            showSavedLocationResult(side: savedSide, name: name)
            return
        }
        
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
    private func showSavedLocationResult(side: String, name: String) {
        resetImageViews()
        
        switch side {
        case "East Side":
            hiUserLabel.text = "Hi \(name) - East Side! 🌏"
            animateImageView(eastSideImageView, scale: 1.1)
        case "West Side":
            hiUserLabel.text = "Hi \(name) - West Side! 🌍"
            animateImageView(westSideImageView, scale: 1.1)
        case "No Side - On the Border":
            hiUserLabel.text = "Hi \(name) - On the Border! 🎯"
            animateImageView(westSideImageView, scale: 1.05)
            animateImageView(eastSideImageView, scale: 1.05)
        default:
            hiUserLabel.text = "Hi \(name)"
        }
        
        enableStartButton()
    }
    
    @objc private func updateImagesForCurrentMode() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        if isDarkMode {
            westSideImageView.image = UIImage(named: "bright_earth_half_left_night")
            eastSideImageView.image = UIImage(named: "bright_earth_half_right_night")
        } else {
            westSideImageView.image = UIImage(named: "bright_earth_half_left")
            eastSideImageView.image = UIImage(named: "bright_earth_half_right")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateImagesForCurrentMode()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let name = textField.text, !name.isEmpty {
            saveUserName(name)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGameScreen" {
            if let gameVC = segue.destination as? GameViewController {
                let playerName = insertNameTextField.text ?? "Player"
                gameVC.playerName = playerName
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func animateImageView(_ imageView: UIImageView?, scale: CGFloat) {
        guard let imageView = imageView else { return }
        
        let isLandscape = view.frame.width > view.frame.height
        let adjustedScale = isLandscape ? scale * 0.8 : scale
        
        UIView.animate(withDuration: 0.3) {
            imageView.transform = CGAffineTransform(scaleX: adjustedScale, y: adjustedScale)
        }
    }
    
    private func resetImageViews() {
        UIView.animate(withDuration: 0.3) {
            self.westSideImageView.transform = CGAffineTransform.identity
            self.eastSideImageView.transform = CGAffineTransform.identity
        }
    }
    
    private func determineSide(from location: CLLocation) -> String {
        let userLatitude = location.coordinate.latitude
        let referenceLatitude = referenceLocation.coordinate.latitude
        
        let tolerance = 0.001
        
        if abs(userLatitude - referenceLatitude) <= tolerance {
            return "No Side - On the Border"
        }
        
        return userLatitude > referenceLatitude ? "East Side" : "West Side"
    }
    
    private func showResult(side: String) {
        userSide = side
        hasLocationBeenDetermined = true
        
        UserDefaults.standard.set(true, forKey: "HasLocationDetermined")
        UserDefaults.standard.set(side, forKey: "UserSide")
        UserDefaults.standard.synchronize()
        
        let name = insertNameTextField.text ?? "User"
        
        resetImageViews()
        
        switch side {
        case "East Side":
            hiUserLabel.text = "Hi \(name) - East Side! 🌏"
            animateImageView(eastSideImageView, scale: 1.1)
        case "West Side":
            hiUserLabel.text = "Hi \(name) - West Side! 🌍"
            animateImageView(westSideImageView, scale: 1.1)
        case "No Side - On the Border":
            hiUserLabel.text = "Hi \(name) - On the Border! 🎯"
            animateImageView(westSideImageView, scale: 1.05)
            animateImageView(eastSideImageView, scale: 1.05)
        default:
            hiUserLabel.text = "Hi \(name) - Location Error"
        }
        
        enableStartButton()
    }
    
    private func enableStartButton() {
        startButton.setTitle("START", for: .normal)
        startButton.backgroundColor = UIColor.systemBlue
        startButton.isEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let side = determineSide(from: location)
        showResult(side: side)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        hiUserLabel.text = "Cannot get location - unable to start game"
        startButton.setTitle("Location Required", for: .normal)
        startButton.backgroundColor = UIColor.systemRed
        startButton.isEnabled = false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            hiUserLabel.text = "Location permission required to play"
            startButton.setTitle("Enable Location", for: .normal)
            startButton.backgroundColor = UIColor.systemOrange
            startButton.isEnabled = false
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
}
