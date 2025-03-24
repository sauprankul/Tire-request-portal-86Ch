# Script to run users Firestore test in the Docker container
Write-Host "Copying users Firestore test to the web container..." -ForegroundColor Cyan
docker cp ./tests/users_firestore_test.rb tire_request_portal-web-1:/tmp/

Write-Host "Running users Firestore test..." -ForegroundColor Cyan
Write-Host "======================================================================="
docker exec tire_request_portal-web-1 ruby /tmp/users_firestore_test.rb
$testResult = $LASTEXITCODE
Write-Host "======================================================================="

if ($testResult -eq 0) {
    Write-Host "Users Firestore test passed!" -ForegroundColor Green
} else {
    Write-Host "Users Firestore test failed!" -ForegroundColor Red
}
