# DictToNote

A [KOReader](https://github.com/koreader/koreader) plugin that adds a **Save + Note** button to the dictionary popup.

## What it does

When you look up a word, the dictionary popup normally only lets you copy or open links. This plugin appends a **Save + Note** button to the popup's action row. Tapping it will:

- take the content of the currently shown dictionary entry (HTML stripped, lists re-formatted as plain text),
- append the selected word/phrase as context,
- create a highlight for the selected text and attach the dictionary entry as a note to it,
- show a "Highlight + Note saved!" confirmation.

In short: one tap turns "look up word" into "word is highlighted with the dictionary entry saved as its note".

## Requirements

- A recent KOReader with the dictionary popup. The plugin uses the `ReaderDictionary:addToDictButtons` API (KOReader PR #15184+) and falls back to the `onDictButtonsReady` hook on older versions.
- A highlighted/selected word when the popup is open.

## Installation

1. Download the latest release zip (`dicttonote.koplugin-<version>.zip`) from [Releases](https://github.com/lukas1/dicttonote.koplugin/releases).
2. Unzip it into KOReader's `plugins/` directory so that `plugins/dicttonote.koplugin/` contains `main.lua` and `_meta.lua`.
3. Restart KOReader. The plugin is enabled by default.

Alternatively, install via [bitesized's plugin manager](https://github.com/bitesized/manager.koplugin) by linking it to this repository.

To uninstall, remove the `dicttonote.koplugin/` folder from `plugins/` and restart.

## Releases

Releases are automated: pushing a version tag (e.g. `v2025.11.25`) builds a zip of the plugin folder (README and workflow files excluded) and publishes a GitHub Release with it. The `workflow_dispatch` workflow allows publishing ad-hoc builds as well.
