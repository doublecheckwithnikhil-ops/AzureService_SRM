# Use the official .NET SDK image
FROM mcr.microsoft.com/dotnet/sdk:8.0

# Install DAB CLI tool
RUN dotnet tool install --global Microsoft.DataApiBuilder --version 1.5.56

# Add DAB to PATH
ENV PATH="${PATH}:/root/.dotnet/tools"

# Set working directory
WORKDIR /app

# Copy configuration files
COPY dab-config.json /app/dab-config.json
COPY .env /app/.env

# Expose port 5000
EXPOSE 5000

# Set environment
ENV ASPNETCORE_ENVIRONMENT=Production

# Start DAB
CMD ["dab", "start", "--config", "/app/dab-config.json"] 