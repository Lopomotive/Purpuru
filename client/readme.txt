This directory is for a potential client that will establish a connection to the server
This means that the client SHOULD NOT be run on the main machine since the
main code base is for a server, but instead on one that you plan to extract
images, code, user data etc to be sent to the server.
Therefore this file will have its own directory that you will transfer
the source and compile to the target client machine or run the binary after
compiling on the clients machine

Note that client does not currently plan on implementing external libs
outside of the systems
