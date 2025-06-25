# electronicadigital-II
Final project-Digital Electronics II-PIC16F887

# 🎮 Simon Dice con PIC16F887-Assembler

Este proyecto implementa el clásico juego **"Simón Dice"**, utilizando exclusivamente los **periféricos del microcontrolador PIC16F887**, programado en lenguaje **Assembler**, y desarrollado completamente en **MPLAB X**.

---

## 🧠 ¿De qué se trata?

El juego consiste en **memorizar y repetir una secuencia de luces** en un conjunto de **8 LEDS**. En cada ronda, se añade un nuevo paso a la secuencia y el jugador debe repetirla correctamente usando un **teclado matricial 4x4**.

La secuencia se genera **aleatoriamente** a partir del ruido presente en el conversor **ADC**. El juego termina cuando el jugador comete un error.

---

## 🔧 Funcionalidades del proyecto

🔌 **PIC16F887** → Microcontrolador principal                                              
💡 **8 LEDs** → Muestran la secuencia que debe memorizar el jugador                    
🎛  **Teclado 4x4** - El jugador ingresa la secuencia que recuerda                           
📟 **Displays 7 segmentos** → Muestran el número de rondas alcanzadas                           
🌀 **ADC** → Se utiliza para generar aleatoriedad a partir de ruido de fondo   
📡 **UART** → Envía la cantidad de aciertos al finalizar la partida a la computadora 

---

## 🕹️ Ejemplo de secuencia

1. Se prende el LED 1 → jugador presiona botón 1  
2. LED 1 - LED 2 → jugador presiona 1, luego 2  
3. LED 1 - LED 2 - LED 8 → jugador presiona 1, 2, 8  
4. LED 1 - LED 2 - LED 8 - LED 3 → jugador presiona 1, 2, 8, 3  
... y así sucesivamente hasta errar.

---

## 🎯 Objetivos técnicos alcanzados

- ✅ Generación de secuencias pseudoaleatorias mediante lectura de ruido en el ADC
- ✅ Control preciso de LEDs mediante PORTD
- ✅ Multiplexado de **displays de 7 segmentos**
- ✅ Manejo del teclado matricial 4x4
- ✅ Captura de teclas vía **interrupciones por cambio de puerto** (PORTB)
- ✅ Comunicación serie **UART asíncrona**
- ✅ Generación de retardo con **timers internos**

---

## 🧑‍💻 Integrantes del equipo

- 🧠 José María Galoppo - [@JoseMGaloppo](https://github.com/JoseMGaloppo)
- 💡 Luis Mariano Rivera - [@lmarian0](https://github.com/lmarian0)

---

## 🧪 Capturas y simulaciones

![WhatsApp Image 2025-06-25 at 11 59 09](https://github.com/user-attachments/assets/1e34ecae-ece0-4be2-9a79-656499367f37)
![WhatsApp Image 2025-06-25 at 12 07 16](https://github.com/user-attachments/assets/e33e0898-4545-4e75-881f-08924f477323)

---

