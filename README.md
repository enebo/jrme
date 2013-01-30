[This is an old repository I had which contained my first experiment in wrapping a 3d scenegraph library.  It was written around jMonkeyEngine 2.x and I am unsure if this even works with jME3 or not.  Be free...]

To run jrme:

1. Get a working version of jmonkeyengine
 (from source)
 - checkout source
 - and dist-all
2. Update bin/sample script
 - define JME_DIR to be directory where you checked out jmonkeyengine
 - change LIB_PATH if you are not on MacOS to proper native directory

To run samples:

bin/sample <name_of_sample>

(e.g. bin/sample king_pong)
