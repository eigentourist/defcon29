nasm -f win64 -o errbox.obj errbox.asm
link errbox.obj /subsystem:windows /out:errbox.exe /debug kernel32.lib user32.lib msvcrt.lib legacy_stdio_definitions.lib