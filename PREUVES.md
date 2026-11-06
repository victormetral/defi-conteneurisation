# Preuves — défi conteneurisation

## Image

- Nom et tag : `defi-conteneurisation:1.0`, construite par Compose à partir du `Dockerfile`.
- Base `node:24-slim`, dépendances installées avec `npm ci --omit=dev`, exécution avec l'utilisateur non root `node`.

## Démarrage

```
$ docker compose up --build -d
$ docker compose ps
NAME                          IMAGE                       COMMAND                  SERVICE   CREATED         STATUS                   PORTS
defi-conteneurisation-db-1    postgres:17                 "docker-entrypoint.s…"   db        6 seconds ago   Up 5 seconds (healthy)   5432/tcp
defi-conteneurisation-web-1   defi-conteneurisation:1.0   "docker-entrypoint.s…"   web       6 seconds ago   Up Less than a second    127.0.0.1:3000->3000/tcp
```

## Vérifications HTTP

```
$ curl -i http://localhost:3000/health
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"status":"ok"}
```

```
$ curl -i http://localhost:3000/
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<h1>Choisis un pseudo</h1> … formulaire …
```

```
$ curl -i --data-urlencode 'pseudo=Ada' http://localhost:3000/
HTTP/1.1 303 See Other
Location: /

See Other. Redirecting to /
```

```
$ curl -i http://localhost:3000/
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<h1>Bonjour Ada</h1>
```

## Persistance

```
$ docker compose down
$ docker compose up -d
$ docker compose ps
NAME                          IMAGE                       COMMAND                  SERVICE   CREATED         STATUS                   PORTS
defi-conteneurisation-db-1    postgres:17                 "docker-entrypoint.s…"   db        6 seconds ago   Up 5 seconds (healthy)   5432/tcp
defi-conteneurisation-web-1   defi-conteneurisation:1.0   "docker-entrypoint.s…"   web       6 seconds ago   Up Less than a second    127.0.0.1:3000->3000/tcp

$ curl -i http://localhost:3000/
HTTP/1.1 200 OK

<h1>Bonjour Ada</h1>
```

Les conteneurs ont été recréés, mais le volume nommé `db-data` a été conservé : le pseudo est toujours là. `docker compose down -v` n'est jamais utilisé, car il supprimerait les données.

## Choix

- **Sécurité** : l'application tourne avec l'utilisateur non root `node`. La base n'est jamais publiée : le port 5432 reste dans le réseau Docker. Seul le port 3000 est publié, et uniquement sur `127.0.0.1`. Les identifiants sont dans `.env`, ignoré par Git.
- **Disponibilité** : `restart: unless-stopped` relance les deux services après un arrêt imprévu. Le `healthcheck` (`pg_isready`) et `depends_on` avec `condition: service_healthy` ne démarrent `web` que lorsque PostgreSQL accepte les connexions.
- **Persistance** : les données sont dans le volume nommé `db-data`, monté sur `/var/lib/postgresql/data`. Elles survivent à `docker compose down` puis `up`, comme le montre la section Persistance.