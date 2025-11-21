FROM python:3.11-alpine

WORKDIR /app

COPY calculator-app.py .
COPY static ./static

# Install Flask
RUN pip install flask

# Install Nginx
#RUN apk add --no-cache nginx

# Configure Nginx
#COPY nginx/default.conf /etc/nginx/conf.d/default.conf

#COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Expose port 5000
EXPOSE 5000

# Correct CMD syntax — use exec form (no brackets inside brackets!)
#CMD sh -c "gunicorn calculator-app:app -c gunicorn.conf.py & nginx -g 'daemon off;'"

CMD ["python3", "calculator-app.py"]
