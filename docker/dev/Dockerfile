# Base image for development
FROM node:18-alpine

# Define the application directory as a build argument
ARG APP_DIR=/hacktrack-testing

# Set the working directory
WORKDIR $APP_DIR

# Create the working directory
RUN mkdir -p $APP_DIR

# Install pnpm globally
RUN npm install -g pnpm

# Copy package.json and pnpm-lock.yaml to the container
COPY package.json pnpm-lock.yaml ./

# Install all dependencies, including devDependencies
RUN pnpm install

# Copy all project files to the container
COPY . .

# Set environment variables
ENV NODE_ENV=development
ENV PORT=3000

# Expose the application port
EXPOSE 3000

# Set the default command to start the development server
CMD ["pnpm", "dev"]
