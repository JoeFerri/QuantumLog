
1. LAZARUS
    1. COMPILE FROM LAZARUS
2.  QLSEMVER
    1. MOVE TO QLSEMVER DIRECTORY
    2. RUN QLSEMVER


## PLANTUML

PREREQUISITES:
1. Place the plantuml.jar library in the directory
    - `vendor/plantuml/plantuml.jar`.
    - Makefile use this variable: `PLANTUML_JAR:=vendor/plantuml/plantuml.jar`

### PNG TO SPRITE

see: [https://plantuml.com/sprite](https://plantuml.com/sprite)

1. MOVE TO PNG DIRECTORY
2. EXECUTE PNG TO SPRITE

    (We assume that the variable PLANTUML has been set in the system with the path (including .jar name) to plantuml.jar)
    
    DOS COMMAND: `java -jar %PLANTUML% -encodesprite {4, 8, 16, 4z, 8z or 16z} {filename}.png > {filename}.sprite`

    DOS EXAMPLE: `java -jar %PLANTUML% -encodesprite 8 example.png > example.sprite`

    Without `>` no file will be created and the sprite will be printed to the console.

### PUML TO MAP

see: [https://plantuml.com/command-line](https://plantuml.com/command-line#f92fb84f0d5ea07f)
see: [https://graphviz.org/docs/outputs/imap/](https://graphviz.org/docs/outputs/imap/)

1. MOVE TO PUML DIRECTORY
2. EXECUTE PUML TO MAP

    (We assume that the variable PLANTUML has been set in the system with the path (including .jar name) to plantuml.jar)
    
    DOS COMMAND: `type {filename}.puml | java -jar "%PLANTUML%" -pipemap > {filename}.cmapx`

    POWERSHELL COMMAND: `cat {filename}.puml | java -jar "$Env:PLANTUML" -pipemap > {filename}.cmapx`