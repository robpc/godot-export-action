# godot-export-action

Action to export fron [Godot Engine](https://godotengine.org/) using the headless version
of the engine. Under the hood, this action uses prebuilt docker images with the export
templates pre-installed to minimize runtime.

Supported versions:
`v4.3`, `v4.2.2`, `v4.2.1`, `v4.2`, `v4.1.3`, `v4.1.2`, `v4.1.1`, `v4.1`, `v4.0.4`, `v4.0.3`, `v4.0.2`, `v4.0.1`, `v4.0`, `v3.5.2`, `v3.5.1`, `v3.5`, `v3.4.5`, `v3.4.4`, `v3.4.3`, `v3.4.2`, `v3.4.1`, `v3.4`, `v3.3.4`, `v3.3.3`, `v3.3.2`, `v3.3.1`, `v3.3` and `v3.2.3`

Future stable are planned to be added as they become available. Feel free to open a request for older versions.

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
        uses: robpc/godot-export-action@v4.3
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
jobs:
  exports:
    name: Export from Godot
    strategy:
      matrix:
        include:
          - preset: html
            export_file: index.html
          - preset: windows
            export_file: maze-test.exe
          - preset: linux
            export_file: maze-test
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v2
        with:
          lfs: true
      - run: echo "version=${GITHUB_REF/refs\/tags\/v/}" >> $GITHUB_ENV
      - name: Export ${{ matrix.preset }} from Godot
        uses: robpc/godot-export-action@v4.3
        with:
          preset: ${{ matrix.preset }}
          export_path: build/${{ matrix.preset }}/${{ matrix.export_file }}
      - name: Bundle ${{ matrix.preset }} export
        uses: montudor/action-zip@v0.1.1
        with:
          args: >-
            zip --junk-paths --recurse-paths
            build/${{ env.package_prefix }}-v${{ env.version }}-${{ matrix.preset }}.zip
            build/${{ matrix.preset }}
      - name: Upload package
        uses: actions/upload-artifact@v2
        with:
          name: build
          path: build/*.zip
      # ... etc
```