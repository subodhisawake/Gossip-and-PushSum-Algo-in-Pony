use "collections"

actor PushSum
  let _main: Main tag

  new create(main: Main tag) =>
    _main = main 

  be run(total_nodes: USize, topology: String) =>
    let nodes = Array[NodeLike tag]
    var i: USize = 0
    while i < total_nodes do
      nodes.push(PushSumNode(_main, i.string()))  // Remove the 'as NodeLike tag' cast
      i = i + 1
    end

    try
      TopologyFunctions[NodeLike tag].create_topology(nodes, topology)?
      _main.out("Topology created: " + topology)
      nodes(0)?.start()
    else
      _main.out("Error creating topology: " + topology)
    end