FROM node:23-alpine

USER node

WORKDIR /usr/app

COPY package*.json ./
RUN npm install --ignore-scripts
RUN npm install --ignore-scripts -g ts-node typescript

COPY . .

CMD ["npm", "run", "start"]
