# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), 
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1] - 11/5/2022
- Initial launch of Forever Engine Feather.

--------------------------
### 11/05/22
- Added Script Support;
- Softcoded Characters with [`HScript`](https://github.com/HaxeFoundation/hscript);
- Psych Character Support;
- Receptors can now be regenerated using Scripts;
- Pausing shouldn't lag anymore;
- Icons are now stored inside the Character's Folder;
- Characters now have fake miss animations (if real ones couldn't be found on offsets).

--------------------------
### 11/05/22

- Receptors can now be manipulated (position, size, etc);
- Scripts now return the error and line properly;
- `Ghost Tapping` is now enabled by default;
- Added character-specific Health Bar Colors;
- Added character-specific Noteskins and Note Splashes;
- UI Class is now a sprite group, meaning it can be manipulated (as in alpha, position, etc) similar to receptors.

--------------------------
### 11/06/22

- Custom Game Over Variables for characters;
- Softcoded Event Notes (with hardcoding still being possible);
- Psych Engine Chart Support (for newer versions);
- Chart Editor Shortcut in `Freeplay`;
- Stages per Chart, rather than Hardcoded;
- On-Screen Error Log, enabled only for build with the `-debug` flag (by @superpowers04);
- Week 6 fixes.

--------------------------
### 11/07/22

- Unhardcoded `Change Character` event;
- Added Personalization Options for Strumline and Hold Note Opacity;
- Improved Selector Options Code;
- Added `Exit to Options` to the Pause Menu;
- Slightly Improved `Options` Menu;
- Weeks are now managed by JSONs in the `assets/` folder 
  * (notice that, while not being as reliable, weeks can still be hardcoded);
- Week Characters are now separated on their own individual images, along with having a JSON file attached for customizzation;
- Difficulty Images are now separated in individual files;
- Added an option to disable `Flashing Lights`.

--------------------------
### 11/08/22

- Scripted Stages;
- `Change Stage` Event;
- You can now regenerate characters by calling `regenerateCharacters()` on `PlayState`;
- Reorganized `source/` folder;
- Removed a few unused imports within the Source Classes;
- Changed Default Script Extension to ``.hx`` so the Haxe formatter actually works with them;
- Center Mark now shows the accurate difficulty name regardless that song has that difficulty or not;
- You won't get misses from pressing keys while the song is ending if Ghost Tapping is not enabled;
- Accuracy shouldn't go over 100% now
  * Additionally, there shouldn't be a percentage symbol while accuracy is at `"N/A"`;
- Icons have infinite frames (to avoid issues with icons in the future).

--------------------------
### 11/09/22

- [WIP] - Error Handling for scripts;
- [SOURCE] - A new sprite class which can be used to attach sprites to other sprites;
- Minor UI Adjustments.

--------------------------
### 11/10/22

- Judgement and Combo Fade Animations are now bound to time
  * In addition, they can (optionally) be recycled sprites rather than being added every note hit;
- [DOCS] - Began working on small bits of documentation which will be expanded and updated with time;
- [WIP] - Mod Management with [`Polymod`](https://github.com/larsiusprime/polymod).

--------------------------
### 11/11/22

- Rewritten Controls.

--------------------------
### 12/11/22

- Support for Text Fonts on Dialogue;
- Chart Editor Tab Fixes;
- Finished Base Game Cutscenes.

--------------------------
### 14/11/22 - 22/11/22
- Rewritten Options Menu.
- Freeplay no longer keeps playing music when you leave (unless holding SHIFT)
- [WIP] Added Character Offset Editor
- Fully Scripted Notetypes (with Psych Conversion support)
- Rewrote Accuracy as an Array with a Typedefine
- Judgement Timing Presets
- Optimized Daddy Dereast and BF Sprites
- New Judgement Image Format
- Notetypes per song (add a `notetypes` folder inside your song's chart folder and put scripts there!)
- [SOURCE] Gameplay Modes (Story, Freeplay, Charting)
- Charts now search for a chart with the `-normal` Difficulty Suffix
- New Crash Dialogue
- [WIP] Custom Difficulties