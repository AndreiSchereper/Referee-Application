# Use the official Flutter image
FROM cirrusci/flutter:latest

# Set environment variables
ENV USER_NAME=flutteruser
ENV USER_HOME=/home/$USER_NAME

# Create a non-root user
RUN useradd -ms /bin/bash $USER_NAME

# Change ownership of the Flutter SDK directory
RUN chown -R $USER_NAME:$USER_NAME /sdks/flutter

# Set the working directory
WORKDIR /app

# Copy the Flutter project files into the container
COPY referee_flutter_app /app

# Change ownership of the app directory to the non-root user
RUN chown -R $USER_NAME:$USER_NAME /app

# Switch to the non-root user
USER $USER_NAME

# Configure Git to treat the Flutter SDK directory as safe
RUN git config --global --add safe.directory /sdks/flutter

# Set the working directory to the Flutter project directory
WORKDIR /app

# Get dependencies
RUN flutter pub get

# Build the app (you can choose web, android, ios as per your needs)
RUN flutter build web

# Expose the port the app runs on
EXPOSE 8080

# Command to run the app
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]
