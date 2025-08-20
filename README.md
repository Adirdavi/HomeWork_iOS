# East vs West – iOS Game (Storyboard-based)

[🎥 Watch the video](https://github.com/Adirdavi/HomeWork_iOS/blob/main/FinalVideo.MP4)

**East vs West** is an iOS card game based on the user's geographic location, developed using UIKit and Storyboard. The game automatically assigns the player to a side (East or West) and pits them against the computer in a series of card battles.

---

## 🎮 Game Overview

- 📍 **Location-based gameplay**: Player side is determined based on real GPS coordinates.
- 📌 Middle point: `Latitude 34.817549`
- 📲 Players are asked to enter a name before the game begins.
- 🕹️ Game starts automatically after the name and location are set.
- 🔄 Cards flip every 3 seconds, and scores are updated in real time.
- 🎯 Stronger card wins the round.
- 🏁 Game ends after 10 rounds, and the winner is displayed.

---

## 🖼️ User Interface (Storyboard)

- Built using **UIKit** with **Storyboard** layout.
- All screens are connected via **segues**.
- Proper handling of **navigation stack** and **ViewController lifecycle**.
- Designed to work in both **portrait mode** and **dark mode**.
  
---

## 🧩 App Features

### ✅ Welcome Screen
- Button to **insert player name** (only on first run).
- App requests location.
- Based on location, determines if you're on the **East Side** or **West Side**.
- Location updates are stopped after determining side.

### ✅ Game Screen
- No buttons — game starts automatically.
- Two card images flip every 3 seconds.
- Score updates after each flip.
- Player vs PC logic.
- Night mode: images and text adapt to system appearance.
- Background music + sound effects on flip/win.

### ✅ Result Screen
- Shows **Winner** and **Final Score**.
- Includes a **"Back to Menu"** button.
- Night mode supported.

---

## 📱 Supported Features

- 📌 CoreLocation (for GPS)
- 🎵 AVFoundation (for music & sound)
- 🌓 Dark Mode support (asset adaptation)
- ⏱️ Timers & lifecycle-aware game flow
- 📐 Works in **portrait mode only**

---

## 🛠️ Tech Stack

- **Language**: Swift
- **UI**: UIKit + Storyboard
- **Xcode Version**: 15+
- **Architecture**: MVC
- **Main Frameworks**: CoreLocation, AVFoundation, UIKit

---

## 🧪 Before Submission Checklist

- [x] Compile and test the app
- [x] Make sure all files are pushed to GitHub
- [x] Add screenshots and video to the repo
- [x] Include `.gitignore` file
- [x] Ensure proper behavior in night mode & portrait orientation
- [x] Stop music/timers on app close or background

---


## 🧑‍💻 Developer

Developed by **Adir**  
Project for iOS development course (Storyboard-based)

---

