#
# QuantumLog
# License: MIT
# Source: https://github.com/JoeFerri/QuantumLog
# Copyright (c) 2025 Giuseppe Ferri <jfinfoit@gmail.com>
#
# S.O.: Windows, Linux
#


###
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
else
    DETECTED_OS := $(shell uname -s)
endif

###
ifeq ($(DETECTED_OS),Windows)
    PATH_SEP := \\
    MKDIR := cmd /C mkdir
    RMDIR := rmdir /s /q
    RM := del /q
    SHELL_STDERR_NULL := 2>nul
    SHELL_NULL := >nul 2>&1
    SHELL_GREP_LINK_UML_CMD := findstr /R /C:"\[\[.*\]\]"
    EXIST_CHECK := if exist
    CAT := type
else
    PATH_SEP := /
    MKDIR := mkdir -p
    RMDIR := rm -rf
    RM := rm -f
    SHELL_STDERR_NULL := 2>/dev/null
    SHELL_NULL := >/dev/null 2>&1
    SHELL_GREP_LINK_UML_CMD := grep -q -E '\[\[.+\]\]'
    EXIST_CHECK := test -d
    CAT := cat
endif

###
define check_uml_link
    $(strip $(shell $(SHELL_GREP_LINK_UML_CMD) $(subst /,\,"$1") $(SHELL_NULL) && echo yes))
endef


###
PLANTUML_JAR:=vendor/plantuml/plantuml.jar
PLANTUML_TO_IMAGE_OPTS:=-Dplantuml.allowmixing=true

###
DIAGRAM_SRC_DIR:=ql-diagram
DIAGRAM_OUT_DIR:=out

###
PUML_FILES:=$(wildcard $(DIAGRAM_SRC_DIR)/*/*.puml)
PNG_FILES:=$(patsubst $(DIAGRAM_SRC_DIR)/%.puml,$(DIAGRAM_OUT_DIR)/%.png,$(PUML_FILES))

PUML_FILES_WITH_LINKS :=
$(foreach f,$(PUML_FILES),\
    $(eval HAS_LINK := $(call check_uml_link,$(f)))\
    $(if $(filter yes,$(HAS_LINK)),\
        $(eval PUML_FILES_WITH_LINKS += $(f)))\
)
MAP_FILES:=$(patsubst $(DIAGRAM_SRC_DIR)/%.puml,$(DIAGRAM_OUT_DIR)/%.cmapx,$(PUML_FILES_WITH_LINKS))


###
.DEFAULT_GOAL := help

.PHONY: all diagram clean test help
all: diagram

###
test:
	@echo DETECTED_OS = $(DETECTED_OS)
	@echo PUML_FILES = $(PUML_FILES)
	@echo PNG_FILES = $(PNG_FILES)
	@echo MAP_FILES = $(MAP_FILES)

###
help:
	@echo Usage:
	@echo $$ make -n : dry-run
	@echo $$ make test : test the Makefile
	@echo $$ make all : generate all project artifacts
	@echo $$ make diagram : generate all diagrams
	@echo $$ make clean : clean all artifacts


###
#diagram: $(PNG_FILES) $(MAP_FILES)
diagram: $(PNG_FILES)

### PNG
$(DIAGRAM_OUT_DIR)/%.png: $(DIAGRAM_SRC_DIR)/%.puml
	@echo " [PNG] $@"
ifeq ($(DETECTED_OS),Windows)
	@$(MKDIR) $(subst /,\,$(@D)) >nul 2>&1 || set dummy=
else
	@$(MKDIR) $(@D)
endif
	@java -jar $(PLANTUML_JAR) $(PLANTUML_TO_IMAGE_OPTS) -tpng -o "$(CURDIR)/$(@D)" "$<"

### CMAPX
# $(DIAGRAM_OUT_DIR)/%.cmapx: $(DIAGRAM_SRC_DIR)/%.puml
# 	@echo " [CMAPX] $@"
# ifeq ($(DETECTED_OS),Windows)
# 	@$(MKDIR) $(subst /,\,$(@D)) >nul 2>&1 || set dummy=
# else
# 	@$(MKDIR) $(@D)
# endif
# 	@$(CAT) $< | java -jar $(PLANTUML_JAR) -pipemap > "$(CURDIR)/$@" || true

###
clean:
	@echo "Cleaning $(DIAGRAM_OUT_DIR)…"
	@$(RMDIR) $(DIAGRAM_OUT_DIR)
