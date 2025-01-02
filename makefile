VENV_DIR := ./lua/markdown-latex-render/image-generator/venv
REQUIREMENTS := ./lua/markdown-latex-render/image-generator/requirements.txt
ACTIVATE := $(VENV_DIR)/bin/activate

# Create virtual environment
$(VENV_DIR):
	@echo "Creating virtual environment in $(VENV_DIR)..."
	python3 -m venv $(VENV_DIR)

# Install dependencies
.PHONY: install
install: $(VENV_DIR)
	@echo "Installing dependencies..."
	. $(ACTIVATE) && pip install --upgrade pip && pip install -r $(REQUIREMENTS)

# Clean up virtual environment
.PHONY: clean
clean:
	@echo "Cleaning up..."
	rm -rf $(VENV_DIR)
