# ---------- Stage 1 : Build ----------
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom first for dependency caching
COPY pom.xml .

RUN mvn -B dependency:go-offline

# Copy project
COPY . .

# Build application
RUN mvn -B clean package -DskipTests

# ---------- Stage 2 : Runtime ----------
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Create non-root user
RUN groupadd -r studentapp && useradd -r -g studentapp studentapp

# Copy generated JAR
COPY --from=builder /app/target/student-ecommerce.jar app.jar

RUN chown studentapp:studentapp app.jar

USER studentapp

EXPOSE 8085

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
CMD wget -qO- http://localhost:8085/ || exit 1

ENTRYPOINT ["java","-jar","app.jar"]