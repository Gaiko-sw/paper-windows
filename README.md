# paper-windows
[PaperWM](https://github.com/paperwm/PaperWM) inspired scrolling window manager for Windows, in Autohotkey

## Usage
After the script is running, newly opened windows will be added automatically (in the future optionally) added to a stack of papers on the first monitor (hopefully configurable in the future). 

After a window is managed and added to the stack, it will automatically be resized vertically to fit the screen, and laid out next to the other windows in the stack.

The stack can be manually scrolled left and right, and the current window can be instantly scrolled to the centre. When a window is focused, the stack is automatically scrolled to make it visible.

Future content:
- columns
- workspaces
- multimonitors
- config
- shortcuts

## Default Keys
Shortcut|Action
---|---
alt + delete|focus previous window
alt + page down|focus next window
alt + insert|centre current window
alt + page up|add floating window to stack
alt + home|scroll stack left
alt + end|scroll stack right 
