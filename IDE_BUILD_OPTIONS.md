# TF536 IDE Interface Build Options

The TF536 board supports two different IDE interface configurations. You must choose ONE of these options during assembly - **do not populate both**.

## Option 1: Unbuffered IDE Interface (Default)

**Components to populate:**
- RN5, RN6, RN7, RN8, RN9, RN10 (0Ω resistor networks)

**Components to leave unpopulated:**
- IC4, IC5, IC6 (buffer ICs)

This is the simpler, lower-cost build option suitable for most applications.

## Option 2: Buffered IDE Interface

**Components to populate:**
- IC4, IC5, IC6 (buffer ICs)

**Components to leave unpopulated:**
- RN5, RN6, RN7, RN8, RN9, RN10 (resistor networks)

The buffered interface provides:
- Better signal integrity for longer IDE cables
- Improved electrical isolation between the TF536 and IDE devices
- Enhanced protection for the CPLD and host system

## Important Notes

⚠️ **WARNING**: Do not populate both the resistor networks (RN5-RN10) and the buffer ICs (IC4-IC6) simultaneously. This will cause signal conflicts and may damage the board.

## Choosing the Right Option

### Use Unbuffered (Default) if:
- Using standard length IDE cables (< 18 inches / 45 cm)
- Cost optimization is important
- Board space or component availability is limited

### Use Buffered if:
- Using longer IDE cables
- Requiring maximum signal integrity
- Operating in electrically noisy environments
- Using multiple IDE devices or CF card adapters with high-speed operation

## Assembly Tips

1. If assembling for the first time, start with the unbuffered option (resistor networks)
2. The resistor networks are typically cheaper and easier to source
3. For JLCPCB assembly, specify which option you want in the assembly notes
4. When hand-soldering, double-check that you're only populating one set of components

## BOM Modifications

When ordering from JLCPCB or generating your BOM:

**For Unbuffered build:**
- Include: RN5, RN6, RN7, RN8, RN9, RN10
- Exclude: IC4, IC5, IC6

**For Buffered build:**
- Include: IC4, IC5, IC6
- Exclude: RN5, RN6, RN7, RN8, RN9, RN10
