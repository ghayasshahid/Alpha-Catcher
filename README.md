# 🎮 AlphaCatcher: 8086 Assembly Game

A real-time, interrupt-driven arcade game developed in **x86 16-bit Assembly Language**.  
The project demonstrates low-level hardware interaction, custom ISR hooking, and direct video memory manipulation.

---

## 🎯 Game Overview

**AlphaCatcher** is a fast-paced "falling alphabet" arcade game where random characters (A–Z) fall from the top of the screen at varying speeds. The player controls a paddle at the bottom and must catch them before they hit the ground.

---

## ✨ Features

- 👤 Single Player & Multiplayer Modes — Play solo or compete with a friend on the same keyboard  
- ⚡ Sprint Mechanic — Hold `Shift` to move at 2x speed  
- 📈 Dynamic Difficulty — Game speed increases after score reaches 8  
- ⏱️ Real-time Stopwatch — Tracks survival time using system timer interrupts  
- 🎨 Custom UI — Start menu and personalized “Desi” game-over messages  

---

## 🛠️ Technical Implementation

This project is built using low-level system programming concepts:

- 🔁 **ISR Hooking**
  - `INT 08h` (System Timer): Handles falling characters + stopwatch concurrently  
  - `INT 09h` (Keyboard): Enables smooth, non-blocking paddle movement  

- 🖥️ **Direct Video Memory Access**
  - Writes directly to `0xB800` segment for fast text-mode rendering  

- 🎲 **Random Number Generation**
  - Uses system clock (`INT 1Ah`) as seed for a Linear Congruential Generator (LCG)  

- 🧠 **Low-Level Memory Control**
  - Manual stack handling and procedure call conventions  

---

## 🚀 How to Run

### Requirements
- DOSBox emulator  
- NASM assembler  

### Steps

```bash
git clone https://github.com/Ahmad-Yar-Khan/AlphaCatcher.git
cd AlphaCatcher
````

### Assemble

```bash
nasm -f bin AlphaCatcher.asm -o AlphaCatcher.com
```

### Run in DOSBox

* Mount the project folder in DOSBox
* Run the game:

```bash
AlphaCatcher.com
```

---

## ⌨️ Controls

| Action     | Single Player | Multiplayer               |
| ---------- | ------------- | ------------------------- |
| Move Left  | Left Arrow    | A (P1) / Left Arrow (P2)  |
| Move Right | Right Arrow   | D (P1) / Right Arrow (P2) |
| Sprint     | Hold Shift    | Hold Shift                |
| Quit Game  | Esc           | Esc                       |
| Restart    | R (Game Over) | R (Game Over)             |

---

## 📚 Academic Context

Developed as part of the **Computer Organization and Assembly Language (COAL)** course at FAST-NUCES Lahore.

This project demonstrates:

* Interrupt-driven programming
* Real-time system behavior in assembly
* Direct hardware-level video manipulation
* Low-level memory and CPU interrupt control
