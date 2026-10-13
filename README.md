# Day.Lit

Ultra-light macOS app that unlocks Liquid Retina XDR / Pro Display XDR brightness for everyday work. Free forever.

[github.com/elija-7580/Day.Lit](https://github.com/elija-7580/Day.Lit)

## Requirements

- MacBook Pro 14″ / 16″ with M-series Pro or Max, or Pro Display XDR
- macOS 13+

## Install

```bash
git clone https://github.com/elija-7580/Day.Lit.git
cd Day.Lit
make run
```

Or:

```bash
make app
open ".build/Day.Lit.app"
```

Unsigned builds may need **System Settings → Privacy & Security → Open Anyway** once.

## Usage

- Opens as a normal app with Dock icon and a small Day.Lit window
- Drag the **Brightness** slider (1.0×–2.0×)
- Optional: only on power adapter, open at login
- Menu bar sun: click to open, right-click for quick controls

## Low-resource design

1×1 EDR Metal primer + one gamma table write. Idle cost is near zero.

## License

MIT.
