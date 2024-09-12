# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory for backend
WORKDIR /app/backend

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0

# Install pip
RUN pip install --upgrade pip

# Copy the requirements file from the backend directory
COPY requirements.txt .

# Install Python dependencies
RUN pip install -r requirements.txt

# Copy the entire backend application code into the container
COPY . .

#COPY best.pt ./best.pt

RUN pip list

# Expose the port the app runs on
EXPOSE 5000

# Command to run the app
CMD ["python", "/app/run.py"]
