# diffkit.app

A native macOS desktop wrapper for [diff-kit.com](https://diff-kit.com), built with C++23 and [Saucer](https://github.com/saucer/saucer). Provides a seamless app experience with a transparent titlebar, repositioned traffic lights, and injected UI tweaks.

## Features

- Native macOS `.app` bundle with custom window chrome
- Transparent titlebar with full-size content view
- Repositioned traffic light buttons
- Injected JavaScript for UI adjustments (draggable nav bar, quick repo navigation via command palette)

## Building

```sh
mkdir build && cd build
cmake .. -G Ninja
ninja
```

The resulting `DiffKit.app` bundle is output to `build/`.
