FROM node:alpine

WORKDIR /plaid-adapter
ADD . .

ENV PORT=6222
EXPOSE 6222

RUN npm install
ENTRYPOINT ["node", "server.js"]
