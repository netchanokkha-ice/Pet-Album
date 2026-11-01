# Pawlum runtime font audit

The standalone prototype is a read-only visual reference. Pawlum bundles only
the font files below; no photographs, mood-board images, or prototype
screenshots are copied into the runtime application.

## Approved runtime fonts

| Runtime family | Source family | Role | License | SHA-256 |
| --- | --- | --- | --- | --- |
| `PawlumJua` | Jua Regular | Friendly display headings | SIL Open Font License 1.1 | `769677aef240bfc3b9965f2b50748075bff885e6c6992fc591a3fb268279f898` |
| `PawlumItim` | Itim Regular | Thai/English body and control text | SIL Open Font License 1.1 | `9164d7eb92ca717b53b07193e3445c96782222d24215151b8d2851b576b17645` |
| `PawlumCaveat` | Caveat variable 400-700 | Short handwritten English accents | SIL Open Font License 1.1 | `0bdb6b660482d31531b3945849fba5916b3ef8695da7024a9e6b9ee3c4157988` |

The files and matching license notices come from the official Google Fonts
repository:

- <https://github.com/google/fonts/tree/main/ofl/jua>
- <https://github.com/google/fonts/tree/main/ofl/itim>
- <https://github.com/google/fonts/tree/main/ofl/caveat>

The application keeps the family names namespaced so later theme work cannot
silently fall back to a network-fetched font with a similar public family name.
The matching `OFL.txt` files are bundled under `assets/fonts/licenses/`.

## Reference-only material

These files remain outside `pawlum_flutter/` and must not be declared in
`pubspec.yaml`:

- `Graphic/Brand CI.png` is a composite brand board, not a production logo
  export. It contains embedded pet photography without separate source or
  rights metadata.
- `Graphic/memory theme/` contains five visual references.
- `Graphic/scrapbook timeline ui theme/` contains six visual references.
- `Pawlum.zip` contains the React prototype, its canvas screenshot, and copies
  of the same reference boards. OpenSpec defines the prototype as read-only.

## Excluded prototype fonts

- Mali is OFL-compatible but appears only as an Itim fallback in the prototype;
  bundling it would duplicate the Thai body role.
- Patrick Hand is OFL-compatible but is loaded by the prototype HTML without
  any JSX usage; Caveat already owns the handwritten accent role.

Revisit this decision only when a shipped surface has a demonstrated glyph or
legibility gap. New visual assets require a source file, an explicit runtime
use, and recorded redistribution rights before they enter this directory.
