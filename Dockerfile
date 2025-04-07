# Use the official Nginx image
FROM nginx:alpine

# Copy your code into the Nginx html directory
COPY ./code /usr/share/nginx/html

# Expose port 8000
EXPOSE 8000

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
