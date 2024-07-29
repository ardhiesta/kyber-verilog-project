# Kyber Verilog Project

This is my journey to implement [CRYSTALS-Kyber](https://pq-crystals.org/kyber/index.shtml) PQC in Verilog HDL. I will record notes on how I debug and understand the code.

Changelog:

v0.1 - 29/07/2024
- SHA3-256 and SHA-512 just works, next: combine to one core and adjust the input length to Kyber requirements
- contains bug, error when input (576*2-16) bit string
