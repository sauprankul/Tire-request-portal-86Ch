# Script to verify Firestore connection in the Docker container
Write-Host "Copying verify Firestore connection script to the web container..." -ForegroundColor Cyan
docker cp ./tests/verify_firestore_connection.rb tire_request_portal-web-1:/tmp/

Write-Host "Running verify Firestore connection script..." -ForegroundColor Cyan
Write-Host "======================================================================="
docker exec tire_request_portal-web-1 ruby /tmp/verify_firestore_connection.rb
$testResult = $LASTEXITCODE
Write-Host "======================================================================="

if ($testResult -eq 0) {
    Write-Host "Firestore connection verification completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Firestore connection verification failed!" -ForegroundColor Red
}
