# Daylit

Ultra-light menu bar app that unlocks Liquid Retina XDR / Pro Display XDR headroom for everyday macOS work.

Clean-room rebuild of the Vivid-class brightness unlock. Free half-screen forever; one-time unlock for the full display (MacBrightness-style).

Not affiliated with Vivid or MacBrightness.

## Requirements

- MacBook Pro 14″ / 16″ with M-series Pro or Max, or Pro Display XDR
- macOS 13+

## Install

```bash
git clone https://github.com/elija-7580/daylit.git
cd daylit
make run
```

Or build only:

```bash
make app
open .build/Daylit.app
```

Unsigned builds may need **System Settings → Privacy & Security → Open Anyway** once.

## Usage

1. Click the Daylit sun in the menu bar.
2. Toggle boost, pick an intensity preset, or open **Settings…**.
3. Free mode brightens half the screen (left or right — choose in Settings).
4. Paste a license key starting with `DAYLIT-` (16+ characters) for full-screen unlock.

Local test key: `DAYLIT-LOCAL-DEV01`

### Settings (kept basic)

- Enable / intensity
- Only on power adapter
- Open at login
- Free half: left or right
- License key

## Low-resource design

| Mode | Mechanism | Idle cost |
| --- | --- | --- |
| **Full** (licensed) | 1×1 EDR Metal primer + gamma table | ~0% CPU/GPU |
| **Free half** | Half-screen multiply overlay at 2 Hz | Small GPU tick |

## Pricing shape (product)

| Tier | Intent |
| --- | --- |
| Free | Half-screen forever |
| Single | One-time full screen (target ~$5) |
| Team / Company | Later |

Checkout not wired yet — local license keys for now.

## License

MIT.
