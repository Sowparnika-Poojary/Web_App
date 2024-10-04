# Base image for building the application
FROM python:3.9-slim AS builder

# Set the working directory
WORKDIR /app

# Copy the requirements file first to leverage Docker cache
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code into the container
COPY . .

# Stage for testing
FROM builder AS tester

# Set PYTHONPATH to the current working directory
ENV PYTHONPATH=/app

# Run the tests (make sure pytest is installed in requirements.txt)
RUN pytest  # This will execute your tests

# Final image for running the application
FROM python:3.9-slim AS final

# Set the working directory
WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app /app

# Ensure Flask and other dependencies are installed in the final image
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Expose the desired port
EXPOSE 5000

# Command to run your Flask application
CMD ["python", "app.py"]