#include "java.h"
#include <boost/regex.hpp>
#include <iterator>
#include <string>

static const std::string POM_XML = R"POM(
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
		 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>in.metguc.evaluator</groupId>
    <artifactId>game-submission</artifactId>
    <packaging>jar</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>java-project</name>
    <url>https://evaluator.metguc.in</url>
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>${JDK_VERSION}</maven.compiler.source>
        <maven.compiler.target>${JDK_VERSION}</maven.compiler.target>
    </properties>
    <dependencies>
        ${JUNIT_VERSION}
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.0.0-M3</version>
                <configuration>
                    <argLine>-Xms6m -Xmx128m</argLine>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
)POM";

static const std::string JUNIT_3_DEPENDENCY = R"JUNIT(
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>3.8</version>
</dependency>
)JUNIT";

static const std::string JUNIT_4_DEPENDENCY = R"JUNIT(
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.12</version>
</dependency>
)JUNIT";

static const std::string JUNIT_5_DEPENDENCY = R"JUNIT(
<dependency>
  <groupId>org.junit.jupiter</groupId>
  <artifactId>junit-jupiter-api</artifactId>
  <version>5.4</version>
  <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter-engine</artifactId>
    <version>5.4</version>
</dependency>
)JUNIT";


static const std::string JUNIT_VERSION_VAR = "${JUNIT_VERSION}";

static const std::string JDK_VERSION_VAR = "${JDK_VERSION}";

static const boost::regex varsRegex(R"REGEX((\$\{JDK_VERSION\})|(\$\{JUNIT_VERSION\}))REGEX");

static std::string getJDKVersionSTR(const evspec::SpecType &specType) {
  // default is 1.8
  switch (specType) {
  case evspec::SpecType::JAVA_1_8:
  default:
    return "1.8";
  }
}

static std::string getJUnitVersionStr(const evspec::JUnitVersion &version) {
  // default is junit 5
  using namespace evspec;
  switch (version) {
  case JUnitVersion::JUnit_3:
    return JUNIT_3_DEPENDENCY;
  case JUnitVersion::JUnit_4:
    return JUNIT_4_DEPENDENCY;
  case JUnitVersion::JUnit_5:
  default:
    return JUNIT_5_DEPENDENCY;
  }
}

void evspec::java::writePom(const fs::path &homePath, const SpecType &specType,
                    const JUnitVersion &junitVersion) {
  fs::path pomPath = fs::path(homePath) /= "pom.xml";
  fs::ofstream pom(pomPath, fs::ofstream::binary | fs::ofstream::out);
  if (!pom.is_open()) {
    throw std::runtime_error("java::writePom : Failed to open pom file");
  }
  auto writeIterator = std::ostream_iterator<char>(pom);
  regex_replace(
      writeIterator, std::begin(POM_XML), std::end(POM_XML), varsRegex,
      [&specType, &junitVersion](const boost::smatch &what, auto out) {
        std::string replacement;
        if (what[1].matched) {
          //   JDK_VERSION
          replacement = getJDKVersionSTR(specType);
        } else {
          //   JUNIT_VERSION
          replacement = getJUnitVersionStr(junitVersion);
        }
        return std::copy(replacement.cbegin(), replacement.cend(), out);
      });
  if (pom.bad()) {
    throw std::runtime_error(
        "java::writePom: irrecoverable stream error while writing pom");
  }
  pom.close();
}