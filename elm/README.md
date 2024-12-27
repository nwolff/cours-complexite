# cours-complexite

Educational tool for teaching algorithm complexity. Students run sorting and search algorithms in the browser, see operation counts, and results are saved live to Firestore so one can watch class progress in real time.

## Architecture

Pure client-side Elm SPA — no server, nothing to install for students.

- **Elm 0.19.1** compiled to `public/dist/elm.js`
- **Firebase Firestore** (named database: `stats`, collection: `stats`) for live result storage
- **Firebase Auth** (Google sign-in) for teacher-only delete access
- **Firebase CDN** loaded directly in `public/index.html` — no bundler, no npm

## Source layout

```
elm.json
src/
  Main.elm          — ports, Model, update, routing
  Types.elm         — all shared types and Msg
  Ui.elm            — shared styles and view helpers
  Chart.elm         — SVG scatter plot (log-scale, colored by algorithm)
  Page/
    Home.elm        — team name entry + team home
    Sort.elm        — sort algorithm runner
    Search.elm      — search algorithm runner
    Stats.elm       — per-team stats + chart
    Teacher.elm     — all-teams view, Google sign-in, delete rows
  Sort.elm          — sort algorithm implementations (return step counts)
  Search.elm        — search algorithm implementations (return guess counts)
public/
  index.html        — Firebase JS bridge (ports ↔ Firestore/Auth)
  dist/elm.js       — compiled output (not committed)
```

## Build

```bash
elm make src/Main.elm --optimize --output=public/dist/elm.js
```

## Local dev

```bash
# Terminal 1 — watch and recompile
npx nodemon --watch src --ext elm --exec "elm make src/Main.elm --output=public/dist/elm.js"

# Terminal 2 — serve with SPA fallback (fixes 404 on refresh)
npx serve --single public
```

## Deploy

Push to `main` — GitHub Actions builds and deploys to GitHub Pages automatically.
See `.github/workflows/deploy.yml`.

After deploying to a new domain, add it to Firebase Console → Authentication → Authorized domains.

## Firebase

- Firestore database name: `stats`
- Security rules: students can create (validated), teacher's Gmail can delete, all can read
- The `dist/elm.js` file is gitignored — the workflow builds it fresh on each deploy

## Algorithms

**Sort** (`Sort.elm`): QuickSort, InsertionSort. Returns comparison count.

**Search** (`Search.elm`): Dichotomy (binary), Sequential, ShuffledSequential, CompletelyRandom. Returns guess count.

## Chart

`Chart.elm` renders a log/log scatter plot (n vs result count) colored by algorithm. Both axes use powers-of-10 ticks derived from the actual data range. No JS or external charting library — pure `elm/svg`.

Colors (Tableau-10): Tri rapide #4e79a7, Tri par insertion #f28e2b, Recherche dichotomique #59a14f, Recherche séquentielle #e15759, Recherche séquentielle mélangée #76b7b2, Recherche aléatoire #b07aa1.

## More

# Deployed automatically when main branch is pushed, to URL:

https://cc.nwolff.info/

## Configuration de firestore

Go to https://console.firebase.google.com/
Select cours-complexite-446113

## Formatting

    npx elm-format --yes src

## Finding outdated packages

    npx elm-json upgrade
