<h1 align="center">💦 mad_goon</h1>

<p align="center">
  <a href="https://github.com/user-attachments/assets/d76f630c-573e-4a92-bb08-eb8528aed983" target="_blank">
    <img src="https://github.com/user-attachments/assets/d76f630c-573e-4a92-bb08-eb8528aed983" alt="mad_goon" />
  </a>
</p>

<p align="center">
  <strong>
    Talk to your disturbingly affectionate AI assistant.
    <br>
    They understand you. They compliment you. They watch you sleep.
  </strong>
</p>

<div align="center">
    <img src="https://img.shields.io/github/downloads/ThatMadCap/mad_goon/total?logo=github" />
    <img src="https://img.shields.io/github/downloads/ThatMadCap/mad_goon/latest/total?logo=github" />
    <img src="https://img.shields.io/github/contributors/ThatMadCap/mad_goon?logo=github" />
    <img src="https://img.shields.io/github/v/release/ThatMadCap/mad_goon?logo=github" />
</div>

<p align="center">
  <a href="#preview">Preview</a> •
  <a href="#philosophy">Philosophy</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#features">Features</a> •
  <a href="#interaction-methods">Interaction Methods</a> •
  <a href="#dependencies">Dependencies</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#speech-reference-spreadsheet">Speech Reference Spreadsheet</a> •
  <a href="#debug">Debug</a> •
  <a href="#locale">Locale</a> •
  <a href="#bridge-system">Bridge System</a> •
  <a href="#support">Support</a> •
  <a href="https://github.com/ThatMadCap/mad_goon/blob/main/LICENSE.md">License</a>
</p>

<p align="center">mad_goon lets players interact with the Prix Luxury AI Concierge voices from GTA Online's <i>Safehouse in the Hills</i> DLC. Type something, and Angel (or Haviland, or OG) responds with semantic matching voice lines - fully offline, no external APIs.</p>

<div style="background:#131C28; color:#fff; border-radius:8px; padding:10px 8px 12px; border-left:4px solid #0b3261; margin:8px 0; font-size:1em;">
  <span style="font-size:1.2em;">ℹ️</span> Please goon responsibly
</div>

## Preview

<p align="center">
  <br/>
  <a href="https://youtu.be/tGrN4xZw3c4" target="_blank">
    <img src="https://img.youtube.com/vi/tGrN4xZw3c4/0.jpg" alt="YouTube Preview"/>
  </a>
  <br/>
  <img src="https://github.com/user-attachments/assets/44121da2-c25e-4377-8717-41ad9b27652e" width="16%" />
  <img src="https://github.com/user-attachments/assets/b8a806b8-f790-4fc1-ba5e-ebdf2a33f672" width="16%" />
  <img src="https://github.com/user-attachments/assets/455d1385-b6a8-425a-aa95-a7e7109085bb" width="16%" />
  <img src="https://github.com/user-attachments/assets/4ff49240-ad40-4d48-a4ed-bbc5918561c7" width="16%" />
  <img src="https://github.com/user-attachments/assets/60eebc31-443d-4355-bbae-2f2d35053b63" width="16%" />
  <img src="https://github.com/user-attachments/assets/9cdc8d72-1be0-45b7-b376-f0b8fac19995" width="16%" />
</p>

## Philosophy

mad_goon was built as an exploration into headless, local semantic interpretation; the kind of language processing that existed before large-scale AI services became the default solution.

While modern AI APIs can solve this problem more effectively, they also introduce external dependencies, ongoing costs, latency, and privacy considerations. This project deliberately avoids those trade-offs by remaining entirely offline and self-contained. The goal is not to compete with modern AI, but to understand and apply classical NLP techniques in a practical, game-focused context.

It's what was cool before ChatGPT made everyone forget that maths could do this too.

## How It Works

1. Player sends a message (e.g. `"hey what's up"`)
2. Text is tokenised and vectorised using **TF-IDF**
3. **Cosine similarity** matches input against a topic corpus
4. Weighted scoring selects the best voice bucket
5. Native ambient speech plays the response

## Features

- **Semantic Matching** - Uses natural language processing to understand player input and selects a fitting response
- **Fully Offline** - No external API calls, no cloud dependencies
- **Context-Aware** - Time of day and player state influence responses
- **Networked Sounds** - Audio playback is synced to nearby players
- **Gendered Addressals** - Auto-detects ped gender, with manual override
- **Multiple Personas** - Switch between Angel, Haviland, and OG
- **Dynamic Objects** - Easily add interactive objects that auto-updates models when changing AI characters
- **Customisable Themes** - Theme system for colours and icons across UIs
- **Developer API** - Exports for integration with other resources
- **Logging** - Player messages and identifiers can be logged to Discord

## Interaction Methods

Interact with the AI in various ways:

| Method       | Requirements                                          |
| ------------ | ----------------------------------------------------- |
| **Target**   | [ox_target](https://github.com/communityox/ox_target) |
| **Menu**     | [ox_lib](https://github.com/CommunityOx/ox_lib)       |
| **Commands** | Built-in                                              |

All methods allow you to:

- Send a message and get a response
- Select the AI persona to use
- Select your preferred addressal
- Get a random message from your AI

### Commands

| Command      | Description                      | Arguments                   |
| ------------ | -------------------------------- | --------------------------- |
| `/ai_talk`   | Talk to the AI                   | `message`                   |
| `/ai_select` | Choose persona                   | `angel` / `haviland` / `og` |
| `/ai_callme` | Set addressal                    | `male` / `female`           |
| `/ai_menu`   | Open AI menu                     |
| `/ai_random` | Play a random speech from the AI |

## Dependencies

- [ox_lib](https://github.com/CommunityOx/ox_lib)
- Game Build **3717+**
- _Optional: [ox_target](https://github.com/communityox/ox_target)_

## Documentation

Refer to the [documentation](https://madcap.gitbook.io/docs/free-resources/mad_goon/developer-documentation) for usage, exports, and integration guides.

## Speech Reference Spreadsheet

You can find a comprehensive spreadsheet of all Prix Luxury AI Concierge speeches in the [docs](docs/) directory:

- [Angel](docs/Prix%20Luxury%20AI%20Concierge%20Speeches%20-%20Angel.csv)
- [Haviland](docs/Prix%20Luxury%20AI%20Concierge%20Speeches%20-%20Haviland.csv)
- [OG](docs/Prix%20Luxury%20AI%20Concierge%20Speeches%20-%20OG.csv)

Each speech entry includes:

- Base ID
- Suffix ID
- Unique ID
- Gender
- Transcript

View Online:
[Google Sheets - Prix Luxury AI Concierge Speeches](https://docs.google.com/spreadsheets/d/1_y0VREgGMlOub51DZfK3kfHQZNCjcbSYcWHBuyD7Z5o/edit?usp=sharing)

## Debug

Debug prints utilise [ox_lib prints](coxdocs.dev/ox_lib/Modules/Print/Shared). To enable, enter in your console:

```
set ox:printlevel debug
```

Replace `debug` with your [desired print level](https://coxdocs.dev/ox_lib/Modules/Print/Shared#levels).

## Locale

Set your language in your `server.cfg`:

```
setr ox:locale en
```

Replace `en` with your desired language. Refer to [ISO 639](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) language codes.

## Bridge System

The resource uses a modular bridge system for compatibility:

- **Notification Bridge**: [ox_lib](https://github.com/CommunityOx/ox_lib), [qb-core](https://github.com/qbcore-framework/qb-core), [mad-thoughts](https://madcap-scripts.tebex.io/package/mad-thoughts), custom
- **Target Bridge:** [ox_target](https://github.com/communityox/ox_target), custom
- **Menu Bridge:** [ox_lib](https://github.com/CommunityOx/ox_lib), custom

All bridges auto-detect and load the appropriate implementation based on the active resources on your server. The notification and menu resources to use can be set in the client config. The bridge system is designed for easy expansion - custom bridges can be added to support other resources as needed.

## Support

Check out other unique scripts on my Tebex, show your ❤️ by buying me a Ko-Fi, or join my Discord server for support:

<a href="https://madcap-scripts.tebex.io" target="_blank"><img src="https://img.shields.io/badge/Tebex-Visit%20Store-24b47e?style=for-the-badge&logo=fivem&logoColor=white" alt="Visit Tebex Store"></a>
<a href="https://ko-fi.com/madcap" target="_blank"><img src="https://img.shields.io/badge/Ko--fi-Support%20Me-ff5e5b?style=for-the-badge&logo=ko-fi&logoColor=white" alt="Support me on Ko-fi"></a>
<a href="https://discord.gg/dTNWpmPGyc" target="_blank"><img src="https://img.shields.io/badge/Discord-Join%20Server-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Join Discord"></a>
