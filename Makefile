# Makefile for minimath

# Compiler and flags
CC = gcc
CFLAGS = -Wall -g

# Flex and flags
LEX = flex
LFLAGS =

# Bison and flags
BISON = bison
BFLAGS = -d

# Linker flags
LIBS = -lfl

# Source files
LEX_SRC = minimath.l
BISON_SRC = minimath.y

# Generated files
LEX_C = minimath.yy.c
BISON_C = minimath.tab.c
BISON_H = minimath.tab.h

C_SOURCES = $(LEX_C) $(BISON_C)

# Target executable
TARGET = minimath

# Default target
all: $(TARGET)

# Rule to link the object files into the final executable
$(TARGET): $(C_SOURCES)
	$(CC) $(CFLAGS) -o $(TARGET) $(C_SOURCES) $(LIBS)

# Rule to generate the C source from the Flex file
$(LEX_C): $(LEX_SRC) $(BISON_H)
	$(LEX) $(LFLAGS) -o $(LEX_C) $(LEX_SRC)

# Rule to generate the C source and header from the Bison file
$(BISON_C) $(BISON_H): $(BISON_SRC)
	$(BISON) $(BFLAGS) -o $(BISON_C) $(BISON_SRC)

# Rule to run the parser on a test file
run: $(TARGET)
	./$(TARGET) test.minimath

# Clean up generated files
clean:
	rm -f $(TARGET) $(C_SOURCES) $(BISON_H)

.PHONY: all clean run
