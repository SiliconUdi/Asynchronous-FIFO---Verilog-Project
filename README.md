# Asynchronous-FIFO---Verilog-Project (RTL to GDSII)
I have implemented asynchronous fifo using verilog code.

This project implements an 8-bit Asynchronous FIFO (First-In-First-Out) memory in Verilog. The FIFO supports independent write and read clocks, uses Gray-coded pointers for safe clock domain crossing, and provides full/empty status flags. A Verilog testbench validates the design with multiple write/read cycles and produces waveforms for analysis. This project demonstrates key concepts in digital design, FPGA/ASIC prototyping, and asynchronous data handling.

1. Designed and implemented an Asynchronous FIFO memory module in Verilog for reliable data transfer between independent clock domains.

2. Implemented full and empty flags using Gray-coded pointers to ensure metastability-free operation.

3. Developed a comprehensive testbench to validate FIFO functionality, including write-read sequences, full/empty detection, and waveform verification.

4. Simulated asynchronous behavior with different write and read clock frequencies to demonstrate robust performance.

5. Gained experience in digital design concepts, such as clock domain crossing, memory synchronization, and FIFO pointer logic.
