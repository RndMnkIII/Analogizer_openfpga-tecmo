
# Analogizer openFPGA Tecmo core for Analogue Pocket

* [2.1] **Analogizer** support added by **RndMnkIII** and based on **nullobject** openfpga-tecmo Pocket port. See more in the Analogizer main repository: [Analogizer](https://github.com/RndMnkIII/Analogizer) [13/02/2025].

This Analogizer core use a configuration file to select Analogizer adapter options, not based on the Pocket's menu system. It is necessary to use [Pupdate](https://github.com/mattpannella/pupdate) release >= 4.3.1 or run an external [utility](https://github.com/RndMnkIII/AnalogizerConfigurator) to generate such a file. Once generated, you must copy the `analogizer.bin` file to the `/Assets/analogizer/common` folder on the Pocket SD card. If this folder does not exist, you must create it. Pupdate does all actions automatically after running this tool. Inside Pupdate navigate to: `Pocket Setup>Analogizer Config>Standard Analogizer Config`, choose Analogizer settings and exit to save to file.




| Video output | Status | SOG Switch(Only R2,R3 Analogizer) |
| :----------- | :----: | :-------------------------------: |     
| RGBS         |  ✅    |     Off                           |
| RGsB         |  ✅    |     On                            |
| YPbPr        |  ✅🔹  |     On                            |
| Y/C NTSC     |  ✅    |     Off                           |
| Y/C PAL      |  ✅    |     Off                           |
| Scandoubler  |  ✅    |     Off                           |

🔹 Tested with Sony PVM-9044D

| :video_game:            | Analogizer A/B config Switch | Status |
| :---------------------- | :--------------------------- | :----: |
| DB15                    | A                            |  ✅    |
| NES                     | A                            |  ✅    |
| SNES                    | A                            |  ✅    |
| PCENGINE                | A                            |  ✅    |
| PCE MULTITAP            | A                            |  ✅    |
| PSX DS/DS2 Digital DPAD | B                            |  ✅    |
| PSX DS/DS2 Analog  DPAD | B                            |  ✅    |

The Analogizer interface allow to mix game inputs from compatible SNAC gamepads supported by Analogizer (DB15 Neogeo, NES, SNES, PCEngine, PSX) with Analogue Pocket built-in controls or from Dock USB or wireless supported controllers (Analogue support).

All Analogizer adapter versions (v1, v2 and v3) has a side slide switch labeled as 'A B' that must be configured based on the used SNAC game controller.
For example for use it with PSX Dual Shock or Dual Shock 2 native gamepad you must position the switch lever on the B side position. For the remaining
game controllers you must switch the lever on the A side position. 
Be careful when handling this switch. Use something with a thin, flat tip such as a precision screwdriver with a 2.0mm flat blade for example. Place the tip on the switch lever and press gently until it slides into the desired position:
```
     ---
   B|O  |A  A/B switch on position B
     ---   
     ---
   B|  O|A  A/B switch on position A
     ---
``` 

**Analogizer** is responsible for generating the correct encoded Y/C signals from RGB and outputs to R,G pins of VGA port. Also redirects the CSync to VGA HSync pin.
The required external Y/C adapter that connects to VGA port is responsible for output Svideo o composite video signal using his internal electronics. Oficially
only the Mike Simone Y/C adapters (active) designs will be supported by Analogizer and will be the ones to use.

Adapted to **Analogizer** by [@RndMnkIII](https://github.com/RndMnkIII).
Support native PCEngine/TurboGrafx-16 2btn, 6 btn gamepads and 5 player multitap using SNAC adapter
and PC Engine cable harness (specific for Analogizer). Many thanks to [Mike Simone](https://github.com/MikeS11/MiSTerFPGA_YC_Encoder) for his great Y/C Encoder project.

For output Scandoubler SVGA video you need to select in Pocket's Menu: `Analogizer Video Out > Scandoubler RGBHV`.

For output Y/C video you need to select in Pocket's Menu: `Analogizer Video Out > Y/C NTSC` or `Analogizer Video Out > Y/C NTSC,Pocket OFF`.

You will need to connect an active VGA to Y/C adapter to the VGA port (the 5V power is provided by VGA pin 9). I'll recomend one of these (active):
* [MiSTerAddons - Active Y/C Adapter](https://misteraddons.com/collections/parts/products/yc-active-encoder-board/)
* [MikeS11 Active VGA to Composite / S-Video](https://ultimatemister.com/product/mikes11-active-composite-svideo/)
* [Active VGA->Composite/S-Video adapter](https://antoniovillena.com/product/mikes1-vga-composite-adapter/)

Using another type of Y/C adapter not tested to be used with Analogizer will not receive official support.

I'll recomend also read this guide for MiSTer FPGA but can applied to Analogizer:
[MiSTer FPGA Documentation: Using Your CRT With MiSTer](https://mister-devel.github.io/MkDocs_MiSTer/advanced/crt/)

=====================================================================
# Tecmo

[![Test](https://github.com/nullobject/openfpga-tecmo/actions/workflows/test.yml/badge.svg)](https://github.com/nullobject/openfpga-tecmo/actions/workflows/test.yml)

## Install

* Download and unzip the latest release
* Copy the release files to your Pocket
* Unzip ROMs and copy them to the `Assets/tecmo/common` directory (e.g. `Assets/tecmo/common/rygar`)

Disclaimer: please don't ask me where to get ROMs, they are not provided with this project.

## Legal

This program is free software: you can redistribute it and/or modify it under the terms of the MIT license.
