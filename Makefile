#
# QuantumLog
# License: MIT
# Source: https://github.com/JoeFerri/QuantumLog
# Copyright (c) 2025 Giuseppe Ferri <jfinfoit@gmail.com>
#
# S.O.: Windows, Linux
#


### ############################################### ENVIRONMENT
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


### ############################################### MAKEFILE
.DEFAULT_GOAL := help

.PHONY: all diagram semver clean test help
all: diagram semver

###
test:
	@echo DETECTED_OS          = $(DETECTED_OS)
	@echo PUML_FILES           = $(PUML_FILES)
	@echo PUML_NO_CODE_FILES   = $(PUML_NO_CODE_FILES)
	@echo PUML_WITH_CODE_FILES = $(PUML_WITH_CODE_FILES)
	@echo PNG_FILES            = $(PNG_FILES)
	@echo PNG_NO_CODE_FILES    = $(PNG_NO_CODE_FILES)
	@echo PNG_WITH_CODE_FILES  = $(PNG_WITH_CODE_FILES)
	@echo MAP_FILES            = $(MAP_FILES)

###
help:
	@echo Usage:
	@echo $$ make -n : dry-run
	@echo $$ make test : test the Makefile
	@echo $$ make all : generate all project artifacts
	@echo $$ make diagram : generate all diagrams
	@echo $$ make semver : generate versioning artifacts (version.json, ql-semver.iuml)
	@echo $$ make clean : clean all artifacts

###
clean:
ifeq ($(DETECTED_OS),Windows)
	@echo " [clean] $(DIAGRAM_OUT_DIR)..."
	@$(RMDIR) "$(subst /,\,$(DIAGRAM_OUT_DIR))" $(SHELL_NULL) || set dummy=
	@echo " [clean] qlsemver..."
	@$(RM) "$(subst /,\,$(VERSION_JSON))" "$(subst /,\,$(QLSEMVER_IUML))" $(SHELL_NULL) || set dummy=
else
	@echo " [clean] $(DIAGRAM_OUT_DIR)..."
	@$(RMDIR) "$(DIAGRAM_OUT_DIR)" $(SHELL_NULL) || set dummy=
	@echo " [clean] qlsemver..."
	@$(RM) "$(VERSION_JSON)" "$(QLSEMVER_IUML)" $(SHELL_NULL) || set dummy=
endif



### ############################################### DIRECTORIES
QLSEMVER_SCRIPT_DIR := scripts/ql-semver
PROJECT_DIR := project
DIAGRAM_SRC_DIR:=ql-diagram
DIAGRAM_SRC_CODE_DIR:=$(DIAGRAM_SRC_DIR)/ql-code
DIAGRAM_OUT_DIR:=out
DIAGRAM_OUT_CODE_DIR:=$(DIAGRAM_OUT_DIR)/ql-code


ifeq ($(DETECTED_OS),Windows)
    EXECUTE_MKDIR = @$(MKDIR) $(subst /,\,$(1)) $(SHELL_NULL) || set dummy=
else
    EXECUTE_MKDIR = @$(MKDIR) $(1)
endif

$(DIAGRAM_SRC_DIR):
	$(eval $(call EXECUTE_MKDIR,$(DIAGRAM_SRC_DIR)))


### ############################################### VERSIONING
ifeq ($(DETECTED_OS),Windows)
    QLSEMVER_SCRIPT := qlsemver.exe
else
    QLSEMVER_SCRIPT := qlsemver
endif

QLSEMVER_CONF_JSON := $(QLSEMVER_SCRIPT_DIR)/conf.json
QUANTUMLOG_LPI := $(PROJECT_DIR)/QuantumLog.lpi

VERSION_JSON := version.json
QLSEMVER_IUML := $(DIAGRAM_SRC_DIR)/ql-semver.iuml

semver: $(VERSION_JSON) $(QLSEMVER_IUML)

$(VERSION_JSON) $(QLSEMVER_IUML): $(QLSEMVER_CONF_JSON) $(QUANTUMLOG_LPI) $(QLSEMVER_SCRIPT_DIR)/$(QLSEMVER_SCRIPT) | $(DIAGRAM_SRC_DIR)
	@echo " [qlsemver] generate versioning artifacts..."
ifeq ($(DETECTED_OS),Windows)
	cmd /C "cd $(QLSEMVER_SCRIPT_DIR) && $(notdir $(QLSEMVER_SCRIPT))"
else
	(cd $(QLSEMVER_SCRIPT_DIR) && ./$(notdir $(QLSEMVER_SCRIPT)))
endif



### ############################################### UML
define check_uml_link
    $(strip $(shell $(SHELL_GREP_LINK_UML_CMD) $(subst /,\,"$1") $(SHELL_NULL) && echo yes))
endef


###
PLANTUML_JAR:=vendor/plantuml/plantuml.jar
PLANTUML_TO_IMAGE_OPTS:=-Dplantuml.allowmixing=true

###
PUML_FILES:=$(wildcard $(DIAGRAM_SRC_DIR)/*/*.puml)
PUML_NO_CODE_FILES:=$(filter-out $(DIAGRAM_SRC_CODE_DIR)/%.puml, $(PUML_FILES))
PUML_WITH_CODE_FILES:=$(filter $(DIAGRAM_SRC_CODE_DIR)/%.puml, $(PUML_FILES))

PNG_FILES:=$(patsubst $(DIAGRAM_SRC_DIR)/%.puml,$(DIAGRAM_OUT_DIR)/%.png,$(PUML_FILES))
PNG_NO_CODE_FILES:=$(patsubst $(DIAGRAM_SRC_DIR)/%.puml,$(DIAGRAM_OUT_DIR)/%.png,$(PUML_NO_CODE_FILES))
PNG_WITH_CODE_FILES:=$(patsubst $(DIAGRAM_SRC_DIR)/%.puml,$(DIAGRAM_OUT_DIR)/%.png,$(PUML_WITH_CODE_FILES))

PUML_FILES_WITH_LINKS :=
$(foreach f,$(PUML_FILES),\
    $(eval HAS_LINK := $(call check_uml_link,$(f)))\
    $(if $(filter yes,$(HAS_LINK)),\
        $(eval PUML_FILES_WITH_LINKS += $(f)))\
)
MAP_FILES:=$(patsubst $(DIAGRAM_SRC_DIR)/%.puml,$(DIAGRAM_OUT_DIR)/%.cmapx,$(PUML_FILES_WITH_LINKS))

#diagram: $(PNG_FILES) $(MAP_FILES)
diagram: $(PNG_FILES)

#$(PNG_NO_CODE_FILES): $(PNG_WITH_CODE_FILES)
#$(PNG_NO_CODE_FILES): $(PUML_WITH_CODE_FILES)
#$(PUML_NO_CODE_FILES): $(PUML_WITH_CODE_FILES)

### PNG
#$(DIAGRAM_OUT_DIR)/%.png: $(DIAGRAM_SRC_DIR)/%.puml $(PUML_WITH_CODE_FILES) semver
$(DIAGRAM_OUT_DIR)/%.png: $(DIAGRAM_SRC_DIR)/%.puml semver
	@echo " [mkdir] Creazione di $(@D)"
	$(eval $(call EXECUTE_MKDIR,$(@D)))
	@echo " [png] $@"
	@java -jar $(PLANTUML_JAR) $(PLANTUML_TO_IMAGE_OPTS) -tpng -o "$(CURDIR)/$(@D)" "$<"

### CMAPX
# $(DIAGRAM_OUT_DIR)/%.cmapx: $(DIAGRAM_SRC_DIR)/%.puml
#	@echo " [mkdir] Creazione di $(@D)"
#	$(eval $(call EXECUTE_MKDIR,$(@D)))
# 	@echo " [cmapx] $@"
# 	@$(CAT) $< | java -jar $(PLANTUML_JAR) -pipemap > "$(CURDIR)/$@" || true
