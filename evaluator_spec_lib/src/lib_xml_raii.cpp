#include "evspec.h"
#include <libxml2/libxml/parser.h>

evspec::LibXmlRaii::LibXmlRaii() {
  xmlInitParser();
}
evspec::LibXmlRaii::~LibXmlRaii() {
  xmlCleanupParser();
}