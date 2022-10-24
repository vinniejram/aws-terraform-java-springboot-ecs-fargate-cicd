FROM openjdk:11

EXPOSE 8080

WORKDIR /applications

COPY target/cargarage-0.0.1-SNAPSHOT.jar /applications/cargarage.jar

ENTRYPOINT ["java","-jar", "cargarage.jar"]