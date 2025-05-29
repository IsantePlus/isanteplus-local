FROM maven:3.6.3-jdk-8

WORKDIR /build

# Leverage Docker cache for dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Now copy the full source code
COPY . .

# Set default command to build at runtime (so host .m2 can be mounted)
CMD ["mvn", "--batch-mode", "--update-snapshots", "package"]
