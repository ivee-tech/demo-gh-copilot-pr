# demo-gh-copilot-pr
Demo showing GH Copilot PR capabilities

## Features

### Saturn Rings
The solar system visualization now includes accurate 3D ring system for Saturn with the following features:
- Realistic ring proportions (inner radius ~1.2x planet radius, outer radius ~2.3x planet radius)
- Axial tilt of 26.7° matching Saturn's actual obliquity
- Transparent ring texture using `assets/saturn-rings.jpg`
- Optimized material settings for clean transparency:
  - `MeshBasicMaterial` with `DoubleSide` rendering
  - `depthWrite: false` to prevent z-fighting
  - `alphaTest: 0.02` for clean edges
  - 80% opacity for realistic appearance
- Ring system rotates with Saturn as a unified group while maintaining axial tilt
- High-resolution ring geometry (128 segments) for smooth appearance
