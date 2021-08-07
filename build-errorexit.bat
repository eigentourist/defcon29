nasm -f win64 -o errorexit.obj errorexit.asm
link errorexit.obj /subsystem:console /out:errorexit.exe /debug kernel32.lib user32.lib msvcrt.lib legacy_stdio_definitions.lib