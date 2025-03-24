# Script to rebuild the Docker containers with the latest code changes
Write-Host "Stopping existing containers..." -ForegroundColor Cyan
docker-compose down

Write-Host "Rebuilding and starting containers..." -ForegroundColor Cyan
docker-compose up -d --build

Write-Host "Containers rebuilt and started." -ForegroundColor Green
Write-Host "You can access the application at http://localhost:3000" -ForegroundColor Green
