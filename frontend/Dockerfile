FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY styles.css /usr/share/nginx/html/styles.css
COPY image.png /usr/share/nginx/html/image.png
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY m6x11.ttf /usr/share/nginx/html/m6x11.ttf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]