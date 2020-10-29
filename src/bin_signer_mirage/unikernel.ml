open Lwt.Infix
module Signer_services = Tezos_signer_services.Signer_services
module RPC_encoding = Tezos_rpc.RPC_encoding
module RPC_directory = Tezos_rpc.RPC_directory

module RPC_logging =
Tezos_event_logging.Internal_event.Legacy_logging.Make (struct
  let name = "rpc"
end)

module Main (_ : Mirage_time.S) (Con : Conduit_mirage.S) = struct
  module Server =
    Resto_cohttp_server_mirage.Server_mirage.Make (RPC_encoding) (RPC_logging)

  let src = Logs.Src.create "conduit_server" ~doc:"Conduit HTTP server"

  module Log = (val Logs.src_log src : Logs.LOG)

  let dir =
    let dir = RPC_directory.empty in
    let dir =
      RPC_directory.register1 dir Signer_services.sign
        (fun pkh signature data ->
          Handler.sign cctxt {pkh; data; signature} ?magic_bytes
            ~check_high_watermark ~require_auth)
    in
    let dir =
      RPC_directory.register1 dir Signer_services.public_key (fun pkh () () ->
          Handler.public_key cctxt pkh)
    in
    RPC_directory.register0 dir Signer_services.authorized_keys (fun () () ->
        if require_auth then
          Handler.Authorized_key.load cctxt
          >>=? fun keys ->
          return_some
            (keys |> List.split |> snd |> List.map Signature.Public_key.hash)
        else return_none)

  let start _time conduit =
    let _address = Key_gen.address () and port = Key_gen.port () in
    Server.launch ~media_types:Tezos_rpc_http.Media_type.all_media_types
    >>= fun _server -> fst (Lwt.wait ())
end
