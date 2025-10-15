PanaderiaWeb - Java 21 upgrade notes

This project has been prepared to build with Java 21 (LTS). The pom.xml sets
source/target to 21 and configures the maven-compiler-plugin release flag.
A maven-enforcer-plugin rule requires JDK 21 or newer at build time.

Steps to build locally (Linux, zsh):

1. Install a Java 21 JDK (Temurin / Adoptium recommended). Example using SDKMAN:

```bash
# install sdkman if you don't have it
curl -s "https://get.sdkman.io" | zsh
source "$HOME/.sdkman/bin/sdkman-init.sh"
# install Java 21
sdk install java 21.0.0-tem
# set as default
sdk default java 21.0.0-tem
```

Or download and extract Temurin 21 and set JAVA_HOME:

```bash
# example: adjust path to the actual extracted JDK
export JAVA_HOME="$HOME/.jdk/temurin-21"
export PATH="$JAVA_HOME/bin:$PATH"
```

2. Verify Java version:

```bash
java -version
# should show a 21.x runtime
```

3. Build with Maven:

```bash
mvn -v
mvn clean package
```

Notes:
- If your CI or environment needs explicit JDK installation, install Temurin/Eclipse Adoptium JDK 21.
- The repository already sets compiler source/target to 21; no source changes were made by this upgrade.
