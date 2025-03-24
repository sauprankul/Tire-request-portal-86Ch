# Script to run simple Firestore test in the Docker container
Write-Host "Copying simple Firestore test to the web container..." -ForegroundColor Cyan
docker cp ./tests/simple_firestore_test.rb tire_request_portal-web-1:/tmp/

Write-Host "Running simple Firestore test..." -ForegroundColor Cyan
Write-Host "======================================================================="
docker exec tire_request_portal-web-1 ruby /tmp/simple_firestore_test.rb
$testResult = $LASTEXITCODE
Write-Host "======================================================================="

if ($testResult -eq 0) {
    Write-Host "Firestore test passed!" -ForegroundColor Green
} else {
    Write-Host "Firestore test failed!" -ForegroundColor Red
}
