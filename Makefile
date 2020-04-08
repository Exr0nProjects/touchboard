CC=g++
CFLAGS="--std=c++20 -I."

default: main.cpp
	$(CC) main.cpp -o made && ./made
