# JLCPCB Ordering Guide for the **TF536** Project

This guide walks you step‑by‑step through ordering the **TF536** PCB from JLCPCB using the files provided in the GitHub repository: <https://github.com/terriblefire/tf536>

It is written for beginners and assumes **no prior PCB ordering experience**.

---

## 📁 1. Download and Extract the Release Package

1. Go to the GitHub repository: <https://github.com/terriblefire/tf536>
2. Open the **Releases** section.
3. Download the **single release ZIP file** (e.g., `tf536_v1.0.0.zip`).
4. Extract the ZIP. You will see a structure like this:

```
assembly/
    tf536_bom.csv
    tf536_cpl.csv

pcb/
    tf536_XXXX.zip   (Gerber manufacturing file)

firmware/
    *.jed files (A500 and CDTV variants)

docs/
    PDF documentation, README, LICENSE, IDE_BUILD_OPTIONS.md
```

The files needed for JLCPCB are:
- **Gerber ZIP file:** located in the `pcb/` folder
- **BOM file:** `assembly/tf536_bom.csv`
- **CPL file:** `assembly/tf536_cpl.csv`

---

## 🏭 2. Start a PCB Order on JLCPCB

1. Go to **https://jlcpcb.com**
2. Click **"Order Now"** or **"Quote Now"**.
3. Drag and drop the **Gerber ZIP file** into the upload area.

JLCPCB will automatically detect the board size and number of layers.

> **Note:** JLCPCB does *not* always detect PCB thickness. For TF536, set **1.6 mm thickness manually**.

---

## ⚙️ 3. Configure the PCB Options (Minimal Setup)

The default settings are fine unless otherwise specified by the project.

Recommended settings:

- **Quantity:** 5 or 10 (your choice)
- **PCB Color:** Any (personal preference)
- **Thickness:** 1.6 mm (set manually if not detected)
- **Surface Finish:** HASL or ENIG (ENIG gives nicer gold pads but costs more)
- **Remove Order Number:** Optional (JLCPCB may charge extra)

Everything else can remain at default unless the project documentation says otherwise.

---

## 🤖 4. Add PCB Assembly (If you want components pre‑soldered)

If this project supports assembly (check the repo):

1. Enable **"PCB Assembly"**
2. Select **Left Side / Top Side** (as required by the project)
3. Upload the following when prompted:
   - **BOM file**
   - **CPL file**

JLCPCB will parse the files and show a component placement preview.

### Review the Assembly Bill of Materials

JLCPCB will display:
- A list of recognised components
- Any unmatched parts (you may need to pick substitutes)
- Costs for assembly

> If any parts show as *"Not Found"*, check the BOM or the GitHub project's documentation for substitute part numbers.

---

## 🔍 5. Review the PCB Preview

You will see:
- The Gerber viewer (copper traces, drill holes, etc.)
- Assembly view (if assembly is enabled)

Make sure:
- The board outline looks correct
- Components appear on the correct side
- No warnings are shown

---

## 🛒 6. Add to Cart and Checkout

1. Click **"Add to Cart"**
2. Verify your order summary
3. Proceed to **Checkout**
4. Enter your shipping address
5. Choose a shipping method (DHL is fastest)
6. Pay using:
   - Credit/Debit card
   - PayPal
   - Other supported methods

---

## 📦 7. Wait for Production

Typical manufacturing times:
- **Bare PCBs:** 2–3 days
- **Assembly:** 3–7 days (depends on part availability)

Shipping time varies by region.

You can track the order progress in your JLCPCB account.

---

## 🎉 8. When the Boards Arrive

Inside the package you will find:
- Your PCBs (bare or assembled)
- Any remaining unused components (for assembly orders)
- QC sticker or summary

Inspect the board visually. If assembled, verify correct component placement.

---

## 🧩 9. Additional Notes for TF536 Users

- **IDE Interface Options:** The TF536 has two mutually exclusive build options for the IDE interface:
  - **Unbuffered (Default):** Populate RN5-RN10 with 0Ω resistor networks
  - **Buffered:** Populate IC4, IC5, IC6 with buffer ICs
  - ⚠️ **Never populate both!** See `IDE_BUILD_OPTIONS.md` in the docs folder for details.
- Check the GitHub repo for **firmware**, **build notes**, or **updates**.
- Some components may need to be hand‑soldered depending on your chosen configuration.
- Refer to the project README for configuration or installation instructions.

---

## ❓ Need Help?
If you want a version with screenshots, clearer beginner steps, or additional troubleshooting (e.g., BOM import errors), just ask and I can extend this document further.

