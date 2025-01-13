FROM node:23-alpine

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

RUN npm install -g ts-node typescript

COPY . .

CMD ["npm", "run", "start"]