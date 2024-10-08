use "random"
use "time" 

actor PushSumNode is NodeLike
  let _main: Main tag
  let _id: String
  var _s: F64
  var _w: F64
  var _old_ratio: F64
  var _rounds_unchanged: USize  
  var _rounds: USize
  let _neighbors: Array[PushSumNode tag]
  let _timers: Timers = Timers
  var _active: Bool = true
  var _terminated: Bool = false

  new create(main: Main tag, id: String) =>
    _main = main
    _id = id
    _s = try 
            id.f64()?
        else
            0.0
        end
    _w = 1.0
    _old_ratio = 0.0
    _rounds = 0
    _rounds_unchanged = 0  
    _neighbors = Array[PushSumNode tag]

  be add_neighbor(neighbor: NodeLike tag) =>
    match neighbor
    | let n: PushSumNode tag => _neighbors.push(n)
    end

  be start() =>
    if _active then
      _send_to_random_neighbor()
      _timers(Timer(PushSumNotify(this), 0, 10_000_000)) // Check every 10ms
    end

  be receive_message(msg: (String | (F64, F64))) =>
    match msg
    | (let s_received: F64, let w_received: F64) =>
      if _active then
        _s = _s + s_received
        _w = _w + w_received
        _send_to_random_neighbor()
      end
    | let _: String =>
      // Ignore string messages in PushSum
      None
    end

  be receive_rumor(rumor: String)=>
    None 

  be _send_to_random_neighbor() =>
  if (_neighbors.size() > 0) and (_w > 0) then
    let s_to_send = _s / 2
    let w_to_send = _w / 2
    _s = _s / 2
    _w = _w / 2
    try
      let rand = Rand(Time.nanos())
      let index = rand.int(_neighbors.size().u64()).usize()
      _neighbors(index)?.receive_message((s_to_send, w_to_send))
    end
  end
  _timers(Timer(PushSumNotify(this), 100_000_000)) // Check again after 100ms



  be check_termination() =>
    if _active then
      let current_ratio = _s / _w
      if (current_ratio - _old_ratio).abs() < 1e-10 then
        _rounds_unchanged = _rounds_unchanged + 1
        if _rounds_unchanged >= 3 then
          _terminate()
        else
          _send_to_random_neighbor()
        end
      else
        _rounds_unchanged = 0
        _send_to_random_neighbor()
      end
      _old_ratio = current_ratio
    end

  be _terminate() =>
    if not _terminated then
      _active = false
      _terminated = true
      _timers.dispose()
      _main.node_terminated(_id)
    end



class PushSumNotify is TimerNotify
  let _node: PushSumNode tag

  new iso create(node: PushSumNode tag) =>
    _node = node

  fun ref apply(timer: Timer, count: U64): Bool =>
    _node.check_termination()
    true

  fun ref cancel(timer: Timer) =>
    None