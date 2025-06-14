
1. LAZARUS
    1. COMPILE FROM LAZARUS
2.  QLSEMVER
    1. MOVE TO QLSEMVER DIRECTORY
    2. RUN QLSEMVER


## PNG TO SPRITE

see: [https://plantuml.com/sprite](https://plantuml.com/sprite)

1. MOVE TO PNG DIRECTORY
2. EXECUTE PNG TO SPRITE

    We assume that the variable PLANTUML has been set in the system with the path (including .jar name) to plantuml.jar
    
    DOS COMMAND: `java -jar %PLANTUML% -encodesprite {4, 8, 16, 4z, 8z or 16z} {filename}.png > {filename}.sprite`

    DOS EXAMPLE: `java -jar %PLANTUML% -encodesprite 8 example.png > example.sprite`

    Without `>` no file will be created and the sprite will be printed to the console.