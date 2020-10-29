open Mirage

let address =
  let doc =
    Key.Arg.info ~doc:"listening address or host name" ["a"; "address"]
  in
  Key.(create "address" Arg.(opt string "localhost" doc))

let port =
  let doc =
    Key.Arg.info ~doc:"listening TCP port or sevice name" ["p"; "port"]
  in
  Key.(create "port" Arg.(opt int 8080 doc))

let main =
  foreign
    ~keys:[Key.abstract address; Key.abstract port]
    ~packages:
      [ package "duration"
      ; package "cohttp-mirage"
      ; package "resto-cohttp-server.mirage"
      ; package "tezos-event-logging"
      ; package "tezos-rpc"
      ; package "tezos-rpc-http"
      ; package "tezos-signer-services"
      ; package "tezos-stdlib" ]
    "Unikernel.Main"
    (time @-> conduit @-> job)

let () =
  let stack = generic_stackv4 default_network in
  let conduit = conduit_direct stack in
  register "hello" [main $ default_time $ conduit]
