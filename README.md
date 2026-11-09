<p align="center">
  <img src="resources/hero.png" alt="Razer macOS Logo" width="120" />
  <h1 align="center">Razer macOS</h1>
  <p align="center">
    <strong>A modern, 100% native macOS app to control Razer Chroma lighting, performance tuning, and peripherals.</strong>
  </p>
  <p align="center">
    <img src="https://img.shields.io/badge/Platform-macOS%2014.0%2B-black?style=flat-square&logo=apple" alt="macOS 14.0+" />
    <img src="https://img.shields.io/badge/Architecture-Universal%20(Apple%20Silicon%20%26%20Intel)-black?style=flat-square" alt="Universal" />
    <img src="https://img.shields.io/badge/Built%20With-Swift%20%26%20SwiftUI-orange?style=flat-square&logo=swift" alt="Swift & SwiftUI" />
    <img src="https://img.shields.io/badge/License-GPL--2.0%20%2F%20LGPL-green?style=flat-square" alt="License" />
  </p>
</p>

<p align="center">
  <img src="screenshots/dark.png" alt="Razer macOS Modern Interface" width="900" />
</p>

---

## Overview

**Razer macOS** has been completely redesigned and re-engineered from the ground up as a **100% native Swift & SwiftUI application**. Say goodbye to heavy Electron wrappers and Node runtimes—the new Razer macOS communicates directly with your Razer hardware through macOS IOKit USB interfaces, delivering instantaneous responsiveness, minimal memory usage, and zero background battery drain.

Whether you are customizing RGB Chroma effects on your keyboard, tuning optical sensor DPI on your mouse, or managing lighting across multiple Razer devices simultaneously, Razer macOS brings a sleek, signature macOS experience to Razer peripherals.

---

## ✨ Features

- **⚡️ 100% Native & Lightweight**: Built purely with Swift and SwiftUI using direct IOKit USB hardware communication. Launches instantly, consumes negligible memory, and requires no kernel extensions (kexts).
- **🎨 Chroma Lighting Studio**:
  - **Dynamic Lighting Effects**: Full visual control for **Static**, **Breathing**, **Spectrum Cycle**, **Wave**, **Reactive**, **Starlight**, and **LED Off**.
  - **Live Chroma Preview**: Real-time ambient glow matching the active lighting effect and color directly in the app.
  - **Preset Color Swatches**: Quick selection for 8 Razer signature colors (*Razer Green, Chroma Cyan, Quartz Pink, Electric Purple, Amber Orange, Cyber Yellow, Signal Red, and Mercury White*) alongside a custom RGB color palette.
  - **LED Brightness Control**: Smooth 0–100% brightness slider with instant jump presets (Off, 25%, 50%, 75%, 100%).
  - **Sync All Devices**: Synchronize lighting effects, colors, and brightness across every connected Razer peripheral with a single click.
- **🎯 Hardware Performance Tuning**:
  - **Sensor Sensitivity**: Tune true hardware optical sensor DPI with precision sliders and quick-preset steps (400, 800, 1600, 2400, 3200, 6400, 12000, 16000 DPI).
  - **Polling Rate Adjustment**: Switch between 125 Hz, 500 Hz, 1000 Hz, and up to 8000 Hz polling rates.
  - **Battery & Charging Telemetry**: Live battery status monitoring and charging indicator for wireless mice and peripherals.
- **📋 Hardware Database & Catalog**:
  - Built-in searchable offline database cataloging **147+ Razer peripherals**.
  - Filter devices by category (Keyboards, Mice, Mouse Mats, Headsets, Laptops, Accessories) or search by model name and USB Product ID (PID).
- **📝 Real-time Activity Logs**:
  - Built-in live diagnostics console displaying USB bus scan results, hardware packet handshakes, and driver status.
- **🖥️ Menu Bar Extra & Background Mode**:
  - Convenient menu bar companion icon (`MenuBarExtra`) for quick status and lighting controls without needing the main window open.
  - Optional Launch at Login integration via macOS `SMAppService`.
- **🧪 Hardware Simulation / Demo Mode**:
  - Built-in peripheral simulation mode to explore and test Chroma effects and performance UI even when no physical Razer hardware is plugged in.
- **🍏 Universal Binary**:
  - Native support for both Apple Silicon (M1, M2, M3, M4 series) and Intel Macs running macOS 14.0 Sonoma or later.

---

## 📥 Download & Installation

### Pre-built App

1. Download the latest release `.dmg` from the [Releases page](https://github.com/1kc/razer-macos/releases).
2. Open the downloaded `.dmg` and drag **Razer macOS.app** into your `/Applications` folder.
3. Launch **Razer macOS** from Launchpad or Spotlight.

> [!NOTE]
> If macOS displays a Gatekeeper prompt on first launch, navigate to **System Settings** > **Privacy & Security**, scroll down to the Security section, and click **Open Anyway**.

---

## 🎛️ App Navigation & Architecture

| Section | Icon | Description |
| :--- | :--- | :--- |
| **Devices** | ⌨️ | View connected Razer hardware, connection status, firmware details, and quick rescan. |
| **Chroma Lighting** | 🪄 | Configure RGB lighting effects, color swatches, brightness levels, and multi-device sync. |
| **Performance** | 🎚️ | Optical sensor DPI sensitivity, USB polling rates, and wireless battery telemetry. |
| **Supported Hardware** | 📋 | Searchable hardware catalog of 147+ Razer devices and capabilities. |
| **Activity Logs** | 📄 | Live driver logs, IOKit USB packet transfers, and diagnostic traces. |
| **Preferences** | ⚙️ | Configure Launch at Login, Menu Bar extra toggle, battery polling intervals, and demo mode. |

---

## 🖱️ Supported Devices

Razer macOS supports a vast catalog of **147+ Razer devices** ported from the [OpenRazer](https://openrazer.github.io) project.

### ⌨️ Keyboards & Keypads
- Razer Anansi
- Razer BlackWidow 2019
- Razer BlackWidow Chroma
- Razer BlackWidow Chroma Tournament Edition
- Razer BlackWidow Chroma V2
- Razer BlackWidow Elite
- Razer BlackWidow Essential
- Razer BlackWidow Lite
- Razer BlackWidow Overwatch
- Razer BlackWidow Stealth
- Razer BlackWidow Stealth Edition
- Razer BlackWidow Ultimate (2012, 2013, 2016)
- Razer BlackWidow V3 / V3 Mini HyperSpeed / V3 Pro (wired) / V3 Tenkeyless
- Razer BlackWidow X Chroma / X Chroma TE / X Ultimate
- Razer Cynosa Chroma / Cynosa Chroma Pro / Cynosa Lite / Cynosa V2
- Razer DeathStalker Chroma / DeathStalker Expert
- Razer Huntsman / Huntsman Elite / Huntsman Mini / Huntsman Mini (JP)
- Razer Huntsman Tournament Edition / Huntsman V2 / Huntsman V2 TKL / Huntsman V2 Analog
- Razer Nostromo
- Razer Orbweaver / Orbweaver Chroma
- Razer Ornata / Ornata Chroma / Ornata Chroma V2
- Razer Tartarus / Tartarus Chroma / Tartarus V2

### 🖱️ Mice
- Razer Abyssus / Abyssus 1800 / Abyssus 2000 / Abyssus Elite D.Va Edition / Abyssus Essential / Abyssus V2
- Razer Atheris
- Razer Basilisk / Basilisk Essential / Basilisk Ultimate / Basilisk V2 / Basilisk V3
- Razer DeathAdder 3.5G / 1800 / 2013 / 3500 / Chroma / Elite
- Razer DeathAdder Essential / Essential White Edition / Essential (2021)
- Razer DeathAdder V2 / V2 Mini / V2 Pro (wired & wireless)
- Razer Diamondback Chroma
- Razer Imperator
- Razer Lancehead Tournament Edition / Lancehead Wired / Lancehead Wireless
- Razer Mamba 2012 / Mamba Elite / Mamba Tournament Edition / Mamba Wired / Mamba Wireless
- Razer Naga 2012 / Naga 2014 / Naga Chroma / Naga Hex / Naga Hex Red / Naga Hex V2
- Razer Naga Left-Handed 2020 / Naga Pro / Naga Trinity
- Razer Orochi 2011 / Orochi 2013 / Orochi Chroma
- Razer Ouroboros
- Razer Taipan
- Razer Viper / Viper 8KHz / Viper Mini / Viper Ultimate (wired & wireless)

### 🟪 Mouse Mats
- Razer Firefly
- Razer Firefly HyperFlux
- Razer Firefly V2
- Razer Goliathus Chroma
- Razer Goliathus Chroma Extended

### 🎧 Audio, Headsets & Stands
- Razer Base Station V2 Chroma
- Razer Kraken / Kraken 7.1 / Kraken 7.1 (Alternate)
- Razer Kraken Kitty Edition
- Razer Kraken Ultimate
- Razer Kraken V2
- Razer Nommo Chroma
- Razer Nommo Pro

### 💻 Blade Laptops
- Razer Blade 2018 (Base / Advanced / Mercury)
- Razer Blade 2019 (Base / Advanced / Mercury)
- Razer Blade Late-2016 / Mid-2017 / Late-2017
- Razer Blade Pro 2017 / Pro 2017 Full HD / Pro Late-2016
- Razer Blade Stealth / Stealth 2019 / Stealth Late-2016 / Mid-2017 / Late-2017 / Late-2019
- Razer Blade Studio Edition 2019
- Razer Blade QHD

### 🔌 Accessories & e-GPUs
- Razer Core X Chroma
- Razer Chroma Base
- Razer Chroma HDK
- Razer Chroma Mug
- Razer Mouse Bungee V3 Chroma
- Razer Mouse Charging Dock
- Razer Thunderbolt 4 Dock Chroma

---

## 🛠️ Developer Usage & Building

Building Razer macOS requires a Mac running macOS 14.0 Sonoma or later with Xcode 15 or 16 installed.

### 1. Clone the repository
```bash
git clone --recursive https://github.com/1kc/razer-macos.git
cd razer-macos
```

### 2. Open in Xcode
Open the Xcode project directly:
```bash
open RazerMacOS.xcodeproj
```

Select the **RazerMacOS** scheme and your Mac as the run destination, then press **Cmd + R** to run or **Cmd + B** to build.

### 3. Build via Command Line
You can also compile a Release build via `xcodebuild`:
```bash
xcodebuild -project RazerMacOS.xcodeproj -scheme RazerMacOS -configuration Release build
```

The compiled binary will be placed in your Xcode build products directory.

---

## 🏗️ Technical Architecture

```
                  ┌────────────────────────────────────────┐
                  │          Razer macOS (SwiftUI)         │
                  │   NavigationSplitView • MenuBarExtra   │
                  └───────────────────┬────────────────────┘
                                      │
                                      ▼
                  ┌────────────────────────────────────────┐
                  │           RazerDeviceManager           │
                  │    Hardware state, Chroma sync & logs  │
                  └───────────────────┬────────────────────┘
                                      │
                                      ▼
                  ┌────────────────────────────────────────┐
                  │          RazerHardwareBridge           │
                  │   Direct C Bridging Header & Wrapper   │
                  └───────────────────┬────────────────────┘
                                      │
                                      ▼
                  ┌────────────────────────────────────────┐
                  │             librazermacos              │
                  │  OpenRazer drivers ported to macOS C   │
                  └───────────────────┬────────────────────┘
                                      │
                                      ▼
                  ┌────────────────────────────────────────┐
                  │           macOS IOKit / USB            │
                  │       (IOUSBDeviceInterface API)       │
                  └───────────────────┬────────────────────┘
                                      │
                                      ▼
                  ┌────────────────────────────────────────┐
                  │        Physical Razer Hardware         │
                  └────────────────────────────────────────┘
```

1. **User Interface (`RazerMacOS`)**: Written completely in SwiftUI with standard macOS system paradigms (`NavigationSplitView`, customizable navigation badges, live animations, and `MenuBarExtra` window styles).
2. **Device Coordination (`RazerDeviceManager`)**: High-level manager keeping track of connected hardware, auto-polling wireless battery levels, coordinating multi-device sync, and logging system events.
3. **Swift-C Bridge (`RazerHardwareBridge`)**: Thread-safe Swift bridge interfacing with low-level C drivers via `RazerMacOS-Bridging-Header.h`.
4. **Driver Layer (`librazermacos`)**: Hardware drivers ported from the OpenRazer project, compiling C routines to construct Razer USB feature reports and custom control transfers.
5. **IOKit Subsystem**: Direct user-space USB communication with hardware via `IOUSBDeviceInterface`—no third-party daemons or kernel extensions needed.

---

## ❓ FAQ & Troubleshooting

| Question | Answer |
| :--- | :--- |
| **Why doesn't changing the color affect my keyboard?** | Your keyboard might be using an onboard memory profile that overrides software commands. Switch to a generic or default onboard profile on the keyboard and try again. |
| **The app says "No Razer Devices Found".** | 1. Ensure your Razer device is connected directly to your Mac or a powered USB hub.<br>2. Click **Rescan Bus** in the Devices view.<br>3. Verify that your device is listed under the **Supported Hardware** catalog.<br>4. You can also turn on **Demo Mode** in Preferences to test the app interface. |
| **Can I rebind keys and customize macros?** | For low-level macOS keyboard remapping and custom macro configurations, we recommend using [Karabiner-Elements](https://karabiner-elements.pqrs.org/). |
| **Does Razer officially support macOS?** | Razer Synapse 3 is currently Windows-only, and Razer has [no announced plans to support macOS](https://mysupport.razer.com/app/answers/detail/a_id/1381/kw/macOS). Razer macOS is an open-source, community-driven project created to bring full control to Mac users. |

---

## 🤝 Contributing

Contributions are warmly welcome! Whether adding support for newly released Razer peripherals, improving lighting animations, or refining performance controls:

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/new-device-support`).
3. Commit your changes (`git commit -m 'Add support for Razer DeathAdder V3'`).
4. Push to your branch (`git push origin feature/new-device-support`).
5. Open a Pull Request.

---

## 📜 Credits & Acknowledgements

Razer macOS builds upon the pioneering work of these amazing open-source projects:

- [OpenRazer](https://github.com/openrazer/openrazer) - The open-source Linux driver suite for Razer peripherals.
- [osx-razer-blade](https://github.com/kprinssu/osx-razer-blade) - Razer Blade management for macOS.
- [osx-razer-led](https://github.com/dylanparker/osx-razer-led) - Early reverse engineering of Razer macOS USB lighting controls.

---

<p align="center">
  <sub>Razer is a trademark of Razer Inc. Razer macOS is an independent open-source project and is not affiliated with, endorsed by, or associated with Razer Inc.</sub>
</p>
