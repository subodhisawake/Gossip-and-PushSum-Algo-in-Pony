use "collections"
use "time"

use @exit[None](status: I32)

actor Main
  let _env: Env
  var _informed_count: USize
  var _stopped_count: USize
  var _total_nodes: USize
  let _timers: Timers = Timers
  var _is_complete: Bool = false
  let _terminator: Terminator

  new create(env: Env) =>
    _env = env
    _informed_count = 0
    _stopped_count = 0
    _total_nodes = 0
    _terminator = Terminator(this)

    try
      let args = env.args
      if args.size() != 4 then
        error
      end

      let algorithm = args(1)?
      let num = args(2)?.u32()?
      let topology = args(3)?

      _total_nodes = num.usize()

      match algorithm
      | "Gossip" =>
        let gossip = Gossip(this)
        gossip.run(_total_nodes, topology)
      | "PushSum" =>
        let pushsum = PushSum(this)
        pushsum.run(_total_nodes, topology)
      else
        error
      end
    else
      usage()
    end

  fun usage() =>
    _env.out.print("Usage: program <Gossip/PushSum> <number_of_nodes> <topology>")
    _env.exitcode(1)

  be node_updated(id: String, is_informed: Bool = false) =>
    if not _is_complete then
      if is_informed then
        _informed_count = _informed_count + 1
        _env.out.print("Node " + id + " informed. Total: " + _informed_count.string() + "/" + _total_nodes.string())
        if _informed_count == _total_nodes then
          _env.out.print("All nodes informed!")
        end
      else
        _stopped_count = _stopped_count + 1
        _env.out.print("Node " + id + " stopped/terminated. Total: " + _stopped_count.string() + "/" + _total_nodes.string())
        if _stopped_count == _total_nodes then
          algorithm_complete()
        end
      end
    end

  be node_informed(id: String) =>
    node_updated(id, true)

  be node_stopped(id: String) =>
    node_updated(id, false)

  be node_terminated(id: String) =>
    node_updated(id, false)

  be check_progress() =>
    if not _is_complete then
      _env.out.print("Progress: " + _informed_count.string() + "/" + _total_nodes.string() + " nodes informed, " +
                     _stopped_count.string() + "/" + _total_nodes.string() + " nodes stopped/terminated")
    end

  be algorithm_complete() =>
    if not _is_complete then
      _is_complete = true
      _env.out.print("Algorithm complete. Total nodes stopped/terminated: " + _stopped_count.string() + "/" + _total_nodes.string())
      _timers.dispose()
      _env.out.print("Exiting program")
      _terminator.terminate(0)
    end

  be timeout() =>
    if not _is_complete then
      _is_complete = true
      _env.out.print("Timeout reached. Nodes informed/terminated: " + _stopped_count.string() + "/" + _total_nodes.string())
      _timers.dispose()
      _env.out.print("Exiting program")
      _terminator.terminate(1)
    end

  be out(msg: String) =>
    _env.out.print(msg)

actor Terminator
  let _main: Main tag
  let _timers: Timers = Timers

  new create(main: Main tag) =>
    _main = main

  be terminate(exit_code: I32) =>
    _timers(Timer(ExitNotify(exit_code), 1_000_000_000))

class ExitNotify is TimerNotify
  let _exit_code: I32

  new iso create(exit_code: I32) =>
    _exit_code = exit_code

  fun ref apply(timer: Timer, count: U64): Bool =>
    @exit(_exit_code)
    false
    