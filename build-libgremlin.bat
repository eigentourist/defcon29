nasm -f win64 -o libgremlin.obj libgremlin.asm
link libgremlin.obj /dll /debug msvcrt.lib kernel32.lib user32.lib /nologo /incremental:no /opt:ref /export:keyboardHook /export:keyboard_hook /out:libgremlin.dll
