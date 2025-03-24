# Script to create an approved admin user in the Docker container
Write-Host "Copying create approved user script to the web container..." -ForegroundColor Cyan
docker cp ./tests/create_approved_user.rb tire_request_portal-web-1:/tmp/

Write-Host "Running create approved user script..." -ForegroundColor Cyan
Write-Host "======================================================================="
docker exec tire_request_portal-web-1 ruby /tmp/create_approved_user.rb
$testResult = $LASTEXITCODE
Write-Host "======================================================================="

if ($testResult -eq 0) {
    Write-Host "Approved admin user created/updated successfully!" -ForegroundColor Green
    Write-Host "You should now be able to sign in with your Google account and be automatically approved." -ForegroundColor Green
} else {
    Write-Host "Approved admin user creation failed!" -ForegroundColor Red
}
