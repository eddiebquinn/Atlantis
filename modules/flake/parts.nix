{ inputs, ... }:

{
  # Declares the `flake.modules` option (per-class module aggregates).
  #
  # This is NOT a flake-parts builtin: it ships as an opt-in extra at
  # `flake-parts.flakeModules.modules`. Without this import, every
  # `flake.modules.*` definition in the tree falls into flake-parts'
  # freeform `flake` output type (lazyAttrsOf (unique raw)), which
  # rejects multiple definitions instead of merging them as modules —
  # surfacing as "infinite recursion" while the error message itself
  # is rendered. See MR !39.
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
