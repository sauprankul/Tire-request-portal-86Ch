# Script to run Firebase tests in the Docker environment
Write-Host "Copying Firebase tests to the web container..." -ForegroundColor Cyan
docker cp ./tests/firebase_tests.rb tire_request_portal-web-1:/tmp/

Write-Host "Running Firebase tests..." -ForegroundColor Cyan
Write-Host "======================================================================="
docker exec tire_request_portal-web-1 ruby /tmp/firebase_tests.rb
$testResult = $LASTEXITCODE
Write-Host "======================================================================="

if ($testResult -eq 0) {
    Write-Host "All Firebase tests passed!" -ForegroundColor Green
} else {
    Write-Host "Firebase tests failed!" -ForegroundColor Red
}
