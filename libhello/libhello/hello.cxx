#include <libhello/hello.hxx>

#include <iostream>
#include <ostream>
#include <stdexcept>

#include <fmt/format.h>

using namespace std;

namespace hello
{
  void say_hello (ostream& o, const string& n)
  {
    if (n.empty ())
      throw invalid_argument ("empty name");

    o << fmt::format("Hello, {}!", n) << std::endl;
  }


  void say_hello()
  {
    std::cout << "Hello!" << std::endl;
  }

}
