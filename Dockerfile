FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy app source
COPY . .

# Build assets if needed (not required for this simple static site)

EXPOSE 5000
CMD [ "node", "server.js" ]
