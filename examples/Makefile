# Makefile for GPU Usage Monitor
# 
# This Makefile builds the gpu_usage program that uses Intel Metrics Discovery library

# Compiler and flags
CC = gcc
CXX = g++
CFLAGS = -Wall -Wextra -O2 -std=c99
CXXFLAGS = -Wall -Wextra -O2 -std=c++11

# Project paths
PROJECT_ROOT = ..
INCLUDE_DIR = $(PROJECT_ROOT)/inc/common/instrumentation/api
LIB_DIR = $(PROJECT_ROOT)/dump/linux64/release/metrics_discovery

# Include and library paths
INCLUDES = -I$(INCLUDE_DIR)
LIBS = -L$(LIB_DIR) -ligdmd -ldl

# Source and target
SOURCE = gpu_usage.c
TARGET = gpu_usage

# Default target
all: $(TARGET)

# Build the gpu_usage program
$(TARGET): $(SOURCE)
	@echo "Building GPU usage monitor..."
	@echo "Include path: $(INCLUDE_DIR)"
	@echo "Library path: $(LIB_DIR)"
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $(TARGET) $(SOURCE) $(LIBS)
	@echo "Build complete: $(TARGET)"

# Clean build artifacts
clean:
	rm -f $(TARGET)
	@echo "Clean complete"

# Install the program (optional)
install: $(TARGET)
	@echo "Installing $(TARGET) to /usr/local/bin/"
	sudo cp $(TARGET) /usr/local/bin/
	@echo "Installation complete"

# Uninstall the program (optional)
uninstall:
	@echo "Removing $(TARGET) from /usr/local/bin/"
	sudo rm -f /usr/local/bin/$(TARGET)
	@echo "Uninstall complete"

# Show help
help:
	@echo "GPU Usage Monitor Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all        - Build the gpu_usage program (default)"
	@echo "  clean      - Remove build artifacts"
	@echo "  install    - Install program to /usr/local/bin (requires sudo)"
	@echo "  uninstall  - Remove program from /usr/local/bin (requires sudo)"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - Intel Metrics Discovery library must be built first"
	@echo "  - Library should be at: $(LIB_DIR)/libigdmd.so"
	@echo "  - Headers should be at: $(INCLUDE_DIR)/"

# Check if required files exist
check:
	@echo "Checking build requirements..."
	@if [ -f "$(INCLUDE_DIR)/metrics_discovery_api.h" ]; then \
		echo "✓ Header file found: $(INCLUDE_DIR)/metrics_discovery_api.h"; \
	else \
		echo "✗ Header file missing: $(INCLUDE_DIR)/metrics_discovery_api.h"; \
		exit 1; \
	fi
	@if [ -f "$(LIB_DIR)/libigdmd.so" ]; then \
		echo "✓ Library file found: $(LIB_DIR)/libigdmd.so"; \
	else \
		echo "✗ Library file missing: $(LIB_DIR)/libigdmd.so"; \
		echo "  Please build the metrics discovery library first:"; \
		echo "  cd .. && mkdir -p build && cd build && cmake .. && make"; \
		exit 1; \
	fi
	@echo "All requirements satisfied"

.PHONY: all clean install uninstall help check