#include "mymodule.hxx"

#include <iostream>

int main (int argc, char* argv[])
{
  using namespace std;

  if (argc < 2)
  {
    cerr << "error: missing name" << endl;
    return 1;
  }

  cout << "Hello, " << argv[1] << '!' << endl;
}

namespace mymodule {
  std::string hello(){ return "Hello!"; }
}
