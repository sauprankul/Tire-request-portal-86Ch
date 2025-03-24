# Script to update files in the Docker container without rebuilding
Write-Host "Copying updated files to the web container..." -ForegroundColor Cyan

# Copy the modified files
docker cp ./frontend/app/views/users/new.html.erb tire_request_portal-web-1:/rails_app/app/views/users/new.html.erb
docker cp ./frontend/app/controllers/users_controller.rb tire_request_portal-web-1:/rails_app/app/controllers/users_controller.rb

Write-Host "Files updated successfully!" -ForegroundColor Green
Write-Host "You can access the application at http://localhost:3000"
