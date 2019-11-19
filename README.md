# graphim
## Turbo Pascal (DOS) Implementation of a real time graphics calculator on top of multi tasking message based component framework.

This was a program I wrote back in the dos area in Turbo pascal.
It uses a reverse polish notation to parse written formula and draw a graph on screen. The graphs can be navigated in real time, zoomed and pan, or with specific coordinates, there are several tools to examin the graph, and the ability to compare it with other graphs or draw it with different styles.

The program is based on a components system I've built for th sake of this program. The components are drawn to the graphics card. The program itslf is an infinit time sharing messages and event loop to emulate multitasking in a single threded dos environment.

Please use dosbox in linux or windows to see the program, it will not run in cmd.
