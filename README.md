# Generating sand dunes proceduraly in godot
<img width="518" alt="dunes" src="https://github.com/user-attachments/assets/0cbd4868-a5cd-4e5f-aa19-0c0780b14a3d">

## Mesh structure
The mesh is generated using the primitive TRIANGLE_STRIP, this saves on memory as the generated triangles share vertexes, however it means that the normals have to be manually computed later in the pipeline. 
<img width="373" alt="mesh" src="https://github.com/user-attachments/assets/0da081db-e04b-48b5-b71b-51946aa9eba2">
## The pipeline
While the mesh is being generated, the function "run_pipeline()" is run on each point, this takes an array of callables and executes them all on the requested point. This structure makes the pipeline very easy to modify as functions can be changed added or removed with very littel code editing, they can even be added programatically if that ever becomes a requirement. Currently the pipeline contains a series of sine waves of decreasing aplitudes and increasing frequencies at varying angles, this creates the bulk of the detail of the sand dunes, this is then followed by a perlin noise layer to ensure that the repeating sine wave patterns to not become repetetive. Finally a all values below a threshold are damped to simulate a bedrock layer.
## Normals
After the next position is generated, the normal for the last triangle created is calculated by cross multiplying differences between the previous three verticies. This part of the process is WIP, and currently leaves some artefacts caused by the fact that when one line of the mesh grid is generated, its normals are calulated before the next line is created, this means that the normals cannot be correctly smoothed.
<img width="538" alt="normal buffer" src="https://github.com/user-attachments/assets/caecb2d2-b3de-4185-89cd-ee51513dd994">

## Known issues
[ ] Jagged edges to terrain

[ ] Normals have "banding" effect

[ ] Performance is poor when working with large grid sizes

[ ] Repetition is noticable at larger grid sizes
