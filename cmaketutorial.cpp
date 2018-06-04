#include "CMakeTutorialConfig.h"
#include <iostream>
using namespace std;

int main(int argc, char *argv[]) {
  cout << "Foo on you." << endl;
  cout << "Version: " << CMAKETUTORIAL_VERSION_MAJOR << "." << CMAKETUTORIAL_VERSION_MINOR << "." << CMAKETUTORIAL_VERSION_PATCH << endl;
}
