use "random"
use "time"
use "collections"

interface NodeLike
  be add_neighbor(neighbor: NodeLike tag)
  be start()
  be receive_message(msg: (String | (F64, F64)))

primitive TopologyFunctions[N: NodeLike tag]
  fun fullnetwork(nodes: Array[N]) =>
    for i in nodes.values() do
      for j in nodes.values() do
        if i isnt j then
          i.add_neighbor(j)
        end
      end
    end

  fun line(nodes: Array[N])? =>
    let size = nodes.size()
    
    for i in Range(0, size) do
      if i > 0 then nodes(i)?.add_neighbor(nodes(i-1)?) end
      if i < (size-1) then nodes(i)?.add_neighbor(nodes(i+1)?) end
    end

  fun grid3d(nodes: Array[N])? =>
    let size = nodes.size()
    let side = (size.f64().cbrt().ceil()).usize()
    
    for i in Range(0, size) do
      let x = i % side
      let y = (i / side) % side
      let z = i / (side * side)
      
      // Left neighbor
      if x > 0 then nodes(i)?.add_neighbor(nodes(i-1)?) end
      // Right neighbor
      if (x < (side-1)) and ((i+1) < size) then nodes(i)?.add_neighbor(nodes(i+1)?) end
      // Front neighbor
      if y > 0 then nodes(i)?.add_neighbor(nodes(i-side)?) end
      // Back neighbor
      if (y < (side-1)) and ((i+side) < size) then nodes(i)?.add_neighbor(nodes(i+side)?) end
      // Down neighbor
      if z > 0 then nodes(i)?.add_neighbor(nodes(i-(side*side))?) end
      // Up neighbor
      if (z < (side-1)) and ((i+(side*side)) < size) then nodes(i)?.add_neighbor(nodes(i+(side*side))?) end
    end

  fun imperfect3d(nodes: Array[N])? =>
    grid3d(nodes)?
    let size = nodes.size()
    let rand = Rand(Time.nanos())
    
    for i in Range(0, size) do
      var random_neighbor = i
      while random_neighbor == i do
        random_neighbor = rand.int(size.u64()).usize()
      end
      nodes(i)?.add_neighbor(nodes(random_neighbor)?)
    end

  fun create_topology(nodes: Array[N], topology: String)? =>
    match topology
    | "fullnetwork" => fullnetwork(nodes)
    | "3d" => grid3d(nodes)?
    | "line" => line(nodes)?
    | "imperfect3d" => imperfect3d(nodes)?
    else
      error
    end 