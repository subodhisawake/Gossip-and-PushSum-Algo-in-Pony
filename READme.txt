How to run this project:
- run the command ponyc to compile the files.
- run the command ".\project2.exe <algorithm> <number of nodes> <topology>"
for example:
.\project2 Gossip 25 fullnetwork
.\project2 PushSum 10 line

Algorithms : 1. Gossip
             2. PushSum

Topologies : 1. "fullnetwork" (Full Network) - Connects every node to every other node.
             2. "3d" (3D Grid) - A three dimensional grid of nodes.
             3. "line" (Line) - A simple linear topology.
             4. "imperfect3d" (Imperfect 3D Grid) - Grid arrangement but a random node is selected. 

Working of the project:
- The program starts in the Main actor's create constructor.
- Command line arguments are parsed:
    The algorithm type ("Gossip" or "PushSum")
    The number of nodes
    The topology type
- The number of nodes is stored in the _total_nodes variable of the Main actor.
- Based on the algorithm type:
    If "Gossip" is specified, a Gossip object is created.
    If "PushSum" is specified, a PushSum object is created.
- The run behavior of the chosen algorithm (Gossip or PushSum) is called with _total_nodes and the topology type.
- In the run behavior:
    An array of NodeLike actors is created, with the number of actors equal to _total_nodes.
    The create_topology function is called to set up the specified network topology.
- For Gossip:
    After creating the topology, the first node receives the initial rumor message.
    Nodes start spreading the rumor to their neighbors.
- For PushSum:
    After creating the topology, the start behavior is called on the first node.
    Nodes begin the PushSum algorithm, sending and receiving values.
- As nodes receive messages:
    For Gossip, the node_informed behavior of Main is called when a node first receives the rumor.
    For PushSum, the node_terminated behavior of Main is called when a node converges.
- The node_updated behavior in the Main actor:
    Increments either the _informed_count (for Gossip) or _stopped_count (for PushSum).
    Prints the current progress.
    Checks if all nodes have been informed/terminated.
- When all nodes are informed (Gossip) or have terminated (PushSum):
    The algorithm_complete behavior of Main is called.
    It prints the completion message and initiates program termination.
- Throughout the process:
    The check_progress behavior may be called periodically to print the current state.
    If a timeout is set, the timeout behavior may be triggered to stop the algorithm if it runs too long.
- The program terminates when either:
    All nodes have been informed/terminated.
    A timeout occurs.
This workflow allows the project to simulate different network topologies and compare the Gossip and PushSum algorithms' performance in various scenarios.
To calculate the time taken to run the project use the PowerShell's Measure-Command, for example:
    Measure-Command { .\project2.exe Gossip 250 imperfect3d }

The Report.pdf file shows the calculated convergence time.



