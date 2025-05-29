OUT_DIR = out
SRC_DIR = src
INCLUDE_DIR = src/include
BIN_DIR = $(OUT_DIR)/bin
OBJ_DIR = $(OUT_DIR)/obj
CC = gcc
STRIP = strip

EXPAT_CFLAGS := $(shell pkg-config --cflags expat 2>/dev/null || echo "")
EXPAT_LIBS := $(shell pkg-config --libs expat 2>/dev/null || echo "-lexpat")

CFLAGS = -Wall -O3 -pedantic -I$(INCLUDE_DIR) $(EXPAT_CFLAGS)
LDFLAGS =
SOURCES = $(SRC_DIR)/xflasher_v23.c $(SRC_DIR)/sha256.c
OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))

.PHONY: all clean check-expat

all: check-expat $(BIN_DIR)/xflasher-ng

check-expat:
	@echo "Checking for libexpat..."
	@pkg-config --exists expat 2>/dev/null || \
	(echo "Cant find expat" && \
	 echo "If build fails, install libexpat-dev (Debian/Ubuntu)")

$(OUT_DIR) $(BIN_DIR) $(OBJ_DIR):
	mkdir -p $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/xflasher-ng: $(OBJECTS) | $(BIN_DIR)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@ $(EXPAT_LIBS)
	$(STRIP) $@
	@echo "Build complete: $@"

clean:
	rm -rf $(OUT_DIR)
