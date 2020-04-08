CC=g++
CFLAGS="-I."
LIBS=-F/System/Library/PrivateFrameworks -framework Foundation -framework MultitouchSupport

default: main.m
	$(CC) $(LIBS) main.m -o made && ./made
