# DigitalLock_FPGAFinalProject
### **Summary:**
The goal for this project was to design a digital lock system which runs on an iCE40-HX8K FPGA development board produced by LATTICE Semiconductor. The locking system was submitted as the final project for UCLA's Honors Digital Design seminar. Video demos available on Youtube: https://www.youtube.com/playlist?list=PLp7B8sCz3dXAKDvw01rWKnELww0g0C28C.

### **Design Structure:**
As an overall structure, the lock makes use of a master controller FSM with multiple datapath modules that handle LED blinking, passcode verification, and keypad number entries. An Arduino connected to a 4 digit 7 segment display was added to make the locked/unlocked status of the system more clearly visible.
![](/images/architecturediagram.jpg)

### **Operation:**
#### *Basic Locking*:
The lock works by storing a user code (UC) and a programming code (PC). UCs must be 4-6 digits long and the PC must be 6 digits long. Users can lock or unlock the lock by entering 9+UC+9, where + signs separate different entries (they are not inputs themselves). In the locked state, LED1 on the FPGA board will be on. In the unlocked state, LED1 will be off. If the additional Arduino code is used with a 7 segement display, the display will also say OPEN or SHUT in concordance with LED1. Any incorrect entries will result in an error as shown by LED3 blinking 3 times.

![](/images/lockopen.jpg)
![](/images/lockshut.jpg)

#### *Reprogramming*:
To change the UC, the user can input 8+PC+8+newUC+8+newUC+8 where + signs separate different entires once again. Entering an 8 while the lock is idling puts the system in the reprogramming command entry mode which allows the user to change the UC that is stored on the device. Any incorrect PCs or UCs will terminate the reprogamming and the system will blink LED3 3 times to indicate an error has occurred. A successful entry of keys will be indicated by LED3 blinking rapidly 5 times. After successful reprogramming, the user may follow the basic locking procedure described above but with the new UC.

#### *Defaults and Initialization*:
Whenever the lock is restarted, the UC starts as 666666 by default. The PC is set to start as 455612 and is immutable while the program is running on the FPGA. To change the defaults, a user can find the starting parameters in the /verilogCode/validityChecker.v file where correctPC and correctUC are declared near line 30. Simply change the parameters and reburn the code onto your FPGA for your own desired functionality.

### **References:**
This project is largely made possible thanks to the instructions and examples provided by Professor Mani Srivastava at the following GitHub repository: https://github.com/nesl/ice40_examples. Follow that link to learn how to design your own FPGA projects and develop on the iCE40 Breakout Board!
