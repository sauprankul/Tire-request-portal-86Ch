# Script to run user find test in the Docker container
Write-Host "Copying user find test to the web container..." -ForegroundColor Cyan
docker cp ./tests/user_find_test.rb tire_request_portal-web-1:/tmp/

Write-Host "Running user find test..." -ForegroundColor Cyan
Write-Host "======================================================================="
docker exec tire_request_portal-web-1 ruby /tmp/user_find_test.rb
$testResult = $LASTEXITCODE
Write-Host "======================================================================="

if ($testResult -eq 0) {
    Write-Host "User find test passed!" -ForegroundColor Green
} else {
    Write-Host "User find test failed!" -ForegroundColor Red
}
