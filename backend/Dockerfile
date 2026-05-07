FROM swipl:latest
WORKDIR /app
COPY main.pl .
EXPOSE 8080
CMD ["swipl", "--stack-limit=256m", "-g", "true", "main.pl"]