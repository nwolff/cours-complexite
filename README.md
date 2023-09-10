# Déployé ici

https://cours-complexite-bppjye22la-oa.a.run.app/

# Développement

## Pour exécuter n'importe quel script qui utilise firestore

    gcloud init

    gcloud auth application-default login

A partir de là il est possible de lancer n'importe quel exécutable python (cli, dump_stats, main, etc)

## Pour vérifier le packaging avant de déployer sur gcloud

    gcloud beta code dev

    docker run -e PORT=80 -p 80:80 --rm -it $(docker build -q .)

# Améliorations

- Vérifier pourquoi parfois on ne peut pas télécharger ses stats (en salle de classe par exemple)

- Changer l'architecture : pour l'instant quand on fait des traitements trop lourds comme par exemple un tri par insertion d'une liste d'un million d'éléments on obtient de la part de google cloud "rate exceeded". Wait dialog after submit ne devient plus nécéssaire si on fait ça. Sticky settings in forms non plus

- Jouer interactivement
