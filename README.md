## `mirage-tezos-signer`

A work-in-progress MirageOS-compatible fork of [`tezos-signer`][tezos-signer],
a remote signatory for Tezos blocks using a secret key.

- Vendors internal `tezos` dependencies in `vendor/`

- Building requires access to the opam repository
  [`CraigFe/tezos-opam-repository`][opam-overlay], which is a fork of the [main
  Tezos opam repository][opam-main] containing the necessary `dune` overlays
  for the repository to build with the (unreleased) Mirage 4.0 toolchain.

[tezos-signer]: https://tezos.gitlab.io/user/key-management.html#signer
[opam-main]: https://gitlab.com/tezos/opam-repository
[opam-overlay]: https://github.com/CraigFe/tezos-opam-repository

### TODO

At time of writing, there are two packages in the dependency graph of the
`tezos-signer-*.opam` packages that are not built with Dune (and for which no
overlays have yet been written):

- `afl-persistent`. This is not an issue, since it is only a test dependency of
  `tezos-base`. An eventual Dune port is tracked by
  [`stedolan/afl-persistent#6`][afl-dune].

- `hacl-star-raw`. This is a bigger issue, as a core dependency of
  `tezos-crypto`. There are MirageOS-compatible cryptography primitives
  available at [`mirage/hacl`][mirage-hacl], but these are not a drop-in
  replacement for `hacl-star-raw`. Repackaging `hacl-star-raw` to use Dune is
  discussed [here][hacl-star-dune].

Once the dependency graph is installable in a Duniverse, the work of extracting
a non-Unix-dependent subgraph can begin.

[afl-dune]: https://github.com/stedolan/ocaml-afl-persistent/issues/6
[mirage-hacl]: https://github.com/mirage/hacl/
[hacl-star-dune]: https://github.com/mirage/hacl/issues/32#issuecomment-628728597
