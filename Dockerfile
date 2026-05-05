FROM openjdk:8
EXPOSE 8080
ADD target/devops-project-1.jar devops-project-1.jar
ENTRYPOINT ["java","-jar","/devops-project-1.jar"]
