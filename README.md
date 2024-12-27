# Version 3 : web statique

Une application web avec rien à installer sur le client, et pas de runtime sur le serveur.
Les algorithmes tournent dans les navigateurs des élèves. Les statistiques sont stockées comme d'habitude sur firestore

Uses https://github.com/IzumiSy/elm-firestore

# PLAN

- Connecting to a db
- algorithms
- Teams
- Automatic deployment

# Deployed automatically when branch main is pushed, to:

https://cc.nwolff.info/

Usage statistics collected with umami.js

---

## Configuration de firestore

https://firebase.google.com/docs/firestore/quickstart

## Adding a page to the spa

    npx elm-spa add

## Start a live dev server

    npx elm-spa server

## Runs suild as you code (without the server)

    npm elm-spa watch

## Running unit tests

    npx elm-test

## Formatting

    npx elm-format --yes src

## Reviewing

Gets a bit confused by elm-spa (which generates code that review cannot see), but gives useful feedback nonetheless

    npx elm-review --template jfmengels/elm-review-config/application src tests

## Building for production

    npx elm-spa build

## Finding outdated packages

    npx elm-json upgrade

## Adding new packages

    elm install elm-time # for example
