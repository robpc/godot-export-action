# godot-export-action

Action to export fron [Godot Engine](https://godotengine.org/) using the headless version
of the engine. Under the hood, this action uses prebuilt docker images with the export
templates pre-installed to minimize runtime. Currently built with versions for `v3.3.2`, `v3.3.1`, `v3.3` and
`v3.2.3`, but future stable are planned to be added as they become available. Feel free to
open a request for older versions.

## Options

| Name                  | Required | Description                                                        |
| --------------------- | -------- | ------------------------------------------------------------------ |
| preset                | true     | name of the export preset                                          |
| export_path           | true     | export path for the executable                                     |
| project_directory     | false    | Directory of the project if not the root                           |
| projectfile_directory | false    | Directory containing the project.godot file if not the project_dir |

## Example

### Simple Example

See working example from [maze-test-game](https://github.com/robpc/maze-test-game)
* [beta.yml](https://github.com/robpc/maze-test-game/blob/main/.github/workflows/beta.yml)
* [Maze Test Deployed](https://robpc.github.io/maze-test-game/)

```yaml
name: Deploy Beta

env:
  package_prefix: maze-test

on:
  push:
    branches:
      - main

jobs:
  exports:
    name: Export from Godot
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v2
        with:
          lfs: true
      - name: Export html from Godot
        uses: robpc/godot-export-action@v3.3.2
        with:
          preset: html
          export_path: build/html/index.html
      - name: Deploy 🚀
        uses: JamesIves/github-pages-deploy-action@4.1.1
        with:
          branch: gh-pages
          folder: build/html
```

### Multi-platform example

See working example from [maze-test-game](https://github.com/robpc/maze-test-game)
* [release.yml](https://github.com/robpc/maze-test-game/blob/main/.github/workflows/release.yml)
* [Maze Test Releases](https://github.com/robpc/maze-test-game/releases)

```yaml
name: Release

env:
  package_prefix: maze-test

on:
  push:
    tags:
      - v*

jobs:
  exports:
    name: Export from Godot
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - preset: html
            export_file: index.html
          - preset: windows
            export_file: maze-test.exe
          - preset: linux
            export_file: maze-test
          - preset: osx
            export_file: maze-test.zip
    steps:
      - name: Check out repository
        uses: actions/checkout@v2
        with:
          lfs: true
      - name: Export ${{ matrix.preset }} from Godot
        uses: robpc/godot-export-action@v3.3.2
        with:
          preset: ${{ matrix.preset }}
          export_path: build/${{ matrix.preset }}/${{ matrix.export_file }}
      - name: Set Version
        env:
          FILENAME: ${{ env.package_prefix }}
          PRESET: ${{ matrix.preset }}
        run: |
          version=${GITHUB_REF/refs\/tags\//}
          echo "package=${FILENAME}-${version}-${PRESET}.zip" >> $GITHUB_ENV
      - name: Bundle ${{ matrix.preset }} export
        uses: montudor/action-zip@v0.1.1
        if: ${{ matrix.preset != 'osx' }}
        with:
          args: zip --junk-paths --recurse-paths build/${{ env.package }} build/${{ matrix.preset }}
      - name: Copy ${{ matrix.preset }} bundle
        if: ${{ matrix.preset == 'osx' }}
        uses: canastro/copy-file-action@0.0.2
        with:
          source: build/${{ matrix.preset }}/${{ matrix.export_file }}
          target: build/${{ env.package }}
      - name: Upload binaries to release
        uses: svenstaro/upload-release-action@v2
        with:
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          file: build/${{ env.package }}
          tag: ${{ github.ref }}
```