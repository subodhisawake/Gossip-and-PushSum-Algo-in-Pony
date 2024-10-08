use "random"
use "time"

actor Node is NodeLike
  let _main: Main tag
  let _id: String
  let _neighbors: Array[Node tag]
  var _rumor_count: USize = 0
  let _timers: Timers = Timers
  var _active: Bool = true

  new create(main: Main tag, id: String) =>
    _main = main
    _id = id
    _neighbors = Array[Node tag]

  be add_neighbor(neighbor: NodeLike tag) =>
    match neighbor
    | let n: Node tag => _neighbors.push(n)
    end
  
  be start() =>
    None
  
  be receive_message(msg: (String | (F64, F64))) =>
    match msg
    | let rumor: String => receive_rumor(rumor)
    | (let _: F64, let _: F64) =>
      // Ignore float pair messages in Gossip
      None
    end

  be receive_rumor(rumor: String) =>
    if _rumor_count < 10 then
      _rumor_count = _rumor_count + 1
      if _rumor_count == 1 then
        _main.node_informed(_id)
      elseif _rumor_count == 10 then
        _main.node_stopped(_id)
      end
    end
    if _active then
      _timers(Timer(SpreadNotify(this), 0, 10_000_000)) // Spread every 10ms
    end

  be spread_rumor() =>
    if _active then
      for neighbor in _neighbors.values() do
        neighbor.receive_rumor("The rumor")
      end
    end

  be stop_spreading() =>
    _active = false
    _timers.dispose()

  be debug_info() =>
    _main.out("Node " + _id + " has " + _neighbors.size().string() + " neighbors")

class SpreadNotify is TimerNotify
  let _node: Node tag

  new iso create(node: Node tag) =>
    _node = node

  fun ref apply(timer: Timer, count: U64): Bool =>
    _node.spread_rumor()
    true

  fun ref cancel(timer: Timer) =>
    None