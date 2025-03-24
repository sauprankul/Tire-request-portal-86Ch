# Script to create an admin user in the Docker container
Write-Host "Copying create admin user script to the web container..." -ForegroundColor Cyan
docker cp ./tests/create_admin_user.rb tire_request_portal-web-1:/tmp/

Write-Host "Running create admin user script..." -ForegroundColor Cyan
Write-Host "======================================================================="
docker exec tire_request_portal-web-1 ruby /tmp/create_admin_user.rb
$testResult = $LASTEXITCODE
Write-Host "======================================================================="

if ($testResult -eq 0) {
    Write-Host "Admin user created/updated successfully!" -ForegroundColor Green
} else {
    Write-Host "Admin user creation failed!" -ForegroundColor Red
}
