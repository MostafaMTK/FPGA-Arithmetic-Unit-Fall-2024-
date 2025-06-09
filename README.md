# 🔢 FPGA Arithmetic Unit — Logic Design Project (Fall 2024)

This project is a Verilog-based Arithmetic Logic Unit (ALU) designed and implemented on the DE1-SoC FPGA development board. It accepts sequential single-digit inputs and arithmetic operations via physical switches, computes intermediate and final results in real-time, and displays them on seven-segment displays. Error states are indicated using onboard LEDs.

---

## 📌 Features

- ➕➖✖️➗ **Basic Operations:** Supports addition, subtraction, multiplication, and division (integer quotient).
- 📥 **Dynamic Input Handling:** Numbers and operations are entered sequentially using FPGA switches.
- 📟 **Live Results:** Intermediate and final results are shown on seven-segment displays after every clock cycle.
- ⚠️ **Error Detection:**
  - Division by zero
  - Zero results
  - Negative results
- 💡 **Visual Indicators:**
  - LEDs for sign, zero, and division-by-zero flags.
- 🧠 **Bonus Mode:** Re-evaluates the expression with proper operator precedence after the final clock cycle.

---

## 🧠 System Architecture

- **Input via Switches:**
  - `SW[1:0]` – Number (2 bits)
  - `SW[2]` – Sign bit (0: negative, 1: positive)
  - `SW[5:4]` – Operation selector (mapped to +, -, *, /)
- **Control:**
  - `KEY[0]` – Clock pulse (registers the current input)
- **Output:**
  - **Seven-Segment Displays** for input preview and result display
  - **LEDR[0]** – Division by zero
  - **LEDR[1]** – Negative result
  - **LEDR[2]** – Zero result

---

## 🛠️ Implementation Details

- Written entirely in **Verilog**, with no built-in arithmetic operators.
- Modular structure:
  - Input Handler
  - Arithmetic Operation Units (custom logic for each)
  - Display Controller
  - Error Detection Module
- Uses **left-to-right** evaluation by default (no operator precedence).
- Bonus module added for **precedence-aware** evaluation.

---

## 💻 Simulation & Testing

### ✅ Simulated with:
- ModelSim & Quartus Prime Waveform Simulation

### ✅ Tested on:
- **DE1-SoC FPGA Board** — Verified real-time functionality:
  - Switch inputs
  - Clock button triggering
  - Display updates
  - LED flag behavior

---

## 📷 Demo

Check out the project and hardware demo on [LinkedIn](https://www.linkedin.com/posts/mostafamohammed2005_im-thrilled-to-share-our-arithmetic-unit-activity-7280257371535265792-OXmb?utm_source=share&utm_medium=member_desktop&rcm=ACoAAEkJgVAB7wgljMDnvHfoQ5tfe6Q-FCFGGak).

---

## 📁 File Structure

```
Calculator.v           # Verilog source code
README.md              # This documentation file
```

---

## 👨‍💻 Authors

This project was developed as part of the CMP101 Logic Design course at Cairo University, Fall 2024.

> **Team Members:**
> - [Mostafa Mohammed](https://www.linkedin.com/in/mostafamohammed2005)
> - [Mariam Sameh](https://www.linkedin.com/in/mariam-sameh-1b726a335/)
> - [Mariam Mohamed](https://www.linkedin.com/in/mariam-mohamed-923025335/)
> - [Moslem Ahmed](https://www.linkedin.com/in/moslem-ahmed-153bb1312/)


---

## 📜 License

This project is for educational use under the Cairo University course CMP101. Feel free to reference or build upon it with attribution.
