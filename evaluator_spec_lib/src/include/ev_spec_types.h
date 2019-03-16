#pragma once
namespace evspec {
enum class SpecType : unsigned char { JAVA_1_8 = 0x01 };
enum class JUnitVersion : unsigned char { JUnit_3 = 0x01, JUnit_4, JUnit_5};
union SpecSubtype
{
  JUnitVersion junitVersion;
};
}