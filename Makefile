CROSS_COMPILE ?=
OUT_DIR = out
SRC_DIR = src
INCLUDE_DIR = src/include
EXTERN_DIR = deps

BIN_DIR = $(OUT_DIR)/bin
OBJ_DIR = $(OUT_DIR)/obj
CC = $(CROSS_COMPILE)gcc
STRIP = $(CROSS_COMPILE)strip

EXPAT_DIR = $(EXTERN_DIR)/libexpat/expat
EXPAT_BUILD_DIR = $(OUT_DIR)/expat-build
EXPAT_INSTALL_DIR = $(OUT_DIR)/expat-install
EXPAT_LIB = $(EXPAT_INSTALL_DIR)/lib/libexpat.a

CFLAGS = -Wall -O3 -pedantic -I$(INCLUDE_DIR) -I$(EXPAT_INSTALL_DIR)/include
LDFLAGS = -L$(EXPAT_INSTALL_DIR)/lib -static

SOURCES = $(SRC_DIR)/xflasher_v23.c $(SRC_DIR)/sha256.c
OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))

.PHONY: all clean distclean expat

all: $(BIN_DIR)/xflasher

$(OUT_DIR) $(BIN_DIR) $(OBJ_DIR):
	mkdir -p $@

$(EXPAT_LIB): | $(OUT_DIR)
	cd $(EXPAT_DIR) && ./buildconf.sh
	mkdir -p $(EXPAT_BUILD_DIR)
	mkdir -p $(EXPAT_INSTALL_DIR)
	cd $(EXPAT_BUILD_DIR) && \
	CC=$(CC) \
	CFLAGS="$(CFLAGS)" \
	../../$(EXPAT_DIR)/configure \
	--prefix=$(abspath $(EXPAT_INSTALL_DIR)) \
	--enable-static \
	--disable-shared \
	--without-docbook \
	--without-xmlwf
	$(MAKE) -C $(EXPAT_BUILD_DIR)
	$(MAKE) -C $(EXPAT_BUILD_DIR) install

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/xflasher: $(OBJECTS) $(EXPAT_LIB) | $(BIN_DIR)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@ -lexpat
	$(STRIP) $@
	@echo "Build complete: $@"

clean:
	rm -rf $(OUT_DIR)
