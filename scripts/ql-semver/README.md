# qlsemver

A command-line semantic versioning generator for Free Pascal/Lazarus QuantumLog project.

## Overview

qlsemver is a utility program that extracts version information from Lazarus project files (`.lpi`) and generates semantic versioning files in multiple formats. It's designed to be used as part of a build pipeline, particularly for the QuantumLog project, to automatically maintain version consistency across different project artifacts.

## Features

- Extracts version information from Lazarus project files
- Generates PlantUML-compatible semver files
- Creates comprehensive JSON version metadata
- Supports pre-release versioning
- Configuration-driven operation
- Robust error handling with detailed error messages

## Requirements

- Free Pascal 3.2+
- Lazarus 4.0+ (for `.lpi` file format compatibility)

## Installation

Compile the program using Free Pascal:

```bash
fpc qlsemver.pas
```

Or use Lazarus IDE to build the project.

## Usage

Place the executable in your project directory alongside the `conf.json` configuration file and run:

```bash
./qlsemver
```

The program will automatically:
1. Read the configuration from `conf.json`
2. Parse the specified Lazarus project file (`.lpi`)
3. Generate the semver and version files as configured

## Configuration

### conf.json Structure

The program requires a `conf.json` file in the same directory as the executable:

```json
{
  "ql-semver_name": "ql-semver.puml",
  "ql-diagram_path": "../../ql-diagram",
  "ql-lpi_name": "QuantumLog.lpi",
  "ql-lpi_path": "../../project",
  "ql-version_name": "version.json",
  "ql-version_path": "../..",
  "authors": [
    "Giuseppe Ferri <jfinfoit@gmail.com>"
  ],
  "license": "MIT",
  "repository": "https://github.com/JoeFerri/QuantumLog",
  "pre-release": "alpha"
}
```

#### Configuration Fields

| Field | Type | Description |
|-------|------|-------------|
| `ql-semver_name` | string | Name of the output semver file (typically `.puml`) |
| `ql-diagram_path` | string | Relative path where the semver file will be created |
| `ql-lpi_name` | string | Name of the Lazarus project file to read |
| `ql-lpi_path` | string | Relative path to the Lazarus project file |
| `ql-version_name` | string | Name of the output JSON version file |
| `ql-version_path` | string | Relative path where the version file will be created |
| `authors` | array[string] | List of project authors with email addresses |
| `license` | string | Project license identifier |
| `repository` | string | Project repository URL |
| `pre-release` | string | Pre-release identifier (e.g., "alpha", "beta", "rc") |

## Input: Lazarus Project File (.lpi)

The program extracts version information from the Lazarus project file's `VersionInfo` section:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CONFIG>
  <ProjectOptions>
    <VersionInfo>
      <MajorVersionNr Value="1"/>
      <MinorVersionNr Value="2"/>
      <RevisionNr Value="3"/>
      <Attributes pvaDebug="False" pvaPreRelease="True"/>
      <StringTable FileDescription="Hauling mission management tool." 
                   ProductName="QuantumLog" 
                   ProductVersion="1.2"/>
    </VersionInfo>
  </ProjectOptions>
</CONFIG>
```

### Extracted Fields

| XML Element | Variable | Description |
|-------------|----------|-------------|
| `MajorVersionNr/@Value` | major | Major version number |
| `MinorVersionNr/@Value` | minor | Minor version number |
| `RevisionNr/@Value` | patch | Patch version number |
| `Attributes/@pvaDebug` | debug | Debug flag (default: false if missing) |
| `Attributes/@pvaPreRelease` | preReleaseOK | Pre-release flag (default: false if missing) |
| `StringTable/@FileDescription` | description | Project description |
| `StringTable/@ProductName` | name | Product name |
| `StringTable/@ProductVersion` | version | Product version string |

## Output Files

### 1. Semver File (e.g., ql-semver.puml)

A PlantUML-compatible file containing the semantic version string:

```
!$semver = "1.2.3-alpha"
```

The format is: `MAJOR.MINOR.PATCH[-PRERELEASE]`

The pre-release suffix is only added if:
- `pvaPreRelease="True"` in the `.lpi` file
- A `pre-release` value is specified in `conf.json`

### 2. Version File (e.g., version.json)

A comprehensive JSON file containing all version and project metadata:

```json
{
  "name": "QuantumLog",
  "description": "Hauling mission management tool.",
  "authors": [
    "Giuseppe Ferri <jfinfoit@gmail.com>"
  ],
  "license": "MIT",
  "repository": "https://github.com/JoeFerri/QuantumLog",
  "date": "2025-06-11",
  "version": "1.2",
  "major": 1,
  "minor": 2,
  "patch": 3,
  "debug": false,
  "pre-release": "alpha",
  "semver": "1.2.3-alpha"
}
```

## Error Handling

The program performs comprehensive validation and will exit with error code 1 in the following cases:

- `conf.json` file not found in program directory
- Invalid JSON syntax in `conf.json`
- Specified `.lpi` file not found
- Invalid XML structure in `.lpi` file
- Missing required XML elements in `.lpi` file
- File system errors (permissions, disk space, etc.)

Error messages are written to stderr with descriptive information about the failure.

## Integration

qlsemver is designed to be integrated into build pipelines and automated workflows. It can be called from:

- Makefiles
- Build scripts
- CI/CD pipelines
- IDE pre-build events
- Version control hooks

## Use Cases

- Automatic generation of version files for documentation systems
- PlantUML diagram version synchronization
- Build artifact versioning
- Release automation
- Version consistency across multiple project files

## Contributing

When contributing to this project, ensure that:
- All changes maintain compatibility with Free Pascal 3.2+
- Error handling is comprehensive and user-friendly
- Documentation is updated to reflect any changes in behavior
- File format specifications remain consistent with existing integrations

## License

### MIT license 

Copyright (c) 2025 Giuseppe Ferri

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.