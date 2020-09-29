# Build Image
FROM clojure:openjdk-16-lein-2.9.3-alpine as builder

WORKDIR /guestbook

# cache deps, don't download the internet if only sources change
COPY project.clj /guestbook/project.clj
RUN lein deps

COPY . /guestbook
RUN lein run migrate
RUN lein uberjar

# Production Image
FROM openjdk:8-alpine
MAINTAINER Paul Bauer <paul.bauer@datadoghq.com>

ENV DATABASE_URL="jdbc:h2:/guestbook/guestbook_dev.db"
EXPOSE 3000
CMD ["java", "-jar", "/guestbook/app.jar"]

COPY --from=builder /guestbook/target/uberjar/guestbook.jar /guestbook/app.jar
COPY --from=builder /guestbook/guestbook_dev.db.mv.db /guestbook/guestbook_dev.db.mv.db
