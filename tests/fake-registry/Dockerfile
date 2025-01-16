FROM node:23-alpine

WORKDIR /usr/app

COPY package*.json ./
RUN npm install --ignore-scripts
RUN npm install --ignore-scripts -g ts-node typescript

COPY . .

USER node

CMD ["npm", "run", "start"]
