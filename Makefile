CC=g++
CFLAGS=-I. -fmodules-ts
LIBS=-F/System/Library/PrivateFrameworks -framework Foundation -framework MultitouchSupport

default: main.m
	$(CC) $(CFLAGS) $(LIBS) main.m -o made && ./made
