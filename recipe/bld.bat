mkdir build
cd build

cmake ^
  -G "NMake Makefiles" ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  ..
nmake install

ctest -C Release --output-on-failure
