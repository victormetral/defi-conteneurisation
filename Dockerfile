# Image de base : Node 24 sur Debian allégée (slim)
FROM node:24-slim
# Dossier de travail dans le conteneur
WORKDIR /app
# Dépendances d'abord : la couche npm ci est réutilisée tant que le lockfile ne change pas
COPY package.json package-lock.json ./
# Installation exacte du lockfile, sans les outils de développement
RUN npm ci --omit=dev
# Le code de l'application
COPY src ./src
# Port sur lequel l'application écoute (documentation)
EXPOSE 3000
# Sécurité : utilisateur non privilégié « node », pas root
USER node
# Démarrage exigé par le défi (forme exec : un mot par case)
CMD ["npm", "start"]
