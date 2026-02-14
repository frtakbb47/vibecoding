# Build Resources

Place your app icons here:

## Required Files

### Windows
- `icon.ico` - 256x256 pixels multi-size ICO file

### macOS
- `icon.icns` - Apple icon format

## Generating Icons

You can use tools like:
- [electron-icon-builder](https://www.npmjs.com/package/electron-icon-builder)
- [IconConverter](https://iconverticons.com/)

### Quick generation with ImageMagick:

```bash
# From a 1024x1024 PNG source:
magick icon-1024.png -resize 256x256 icon.ico
magick icon-1024.png icon.icns
```

## Placeholder

If you don't have icons yet, the app will still work but won't have a custom icon.
