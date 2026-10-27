# fusesoc-cores on CAPI=3

This branch (`capi3-migrate`) converts the core library to CAPI=3 to test
`fusesoc core migrate` and CAPI=3 on real cores. It needs the CAPI=3 branch of FuseSoC
and Edalize 0.6.8.

## Status

| | Count |
|---|---|
| Core files | 180 |
| Converted to CAPI=3 | 180 |
| … of which with targets left unconverted | 25 |
| Left on CAPI=2 | 0 |
| Cores that load (`fusesoc core list`) | 180 |

`fusesoc run --setup` of every target with a flow (197), compared with the EDAM
CAPI=2 produces for the same target:

| Result | Targets |
|---|---|
| Same EDAM as CAPI=2 | 184 |
| Intended difference | 5 |
| Fails under both CAPI=2 and CAPI=3 | 8 |
| Works under CAPI=2, broken under CAPI=3 | 0 |

- **Intended difference:** the `sim` targets of blinky 0, 1.0 and 1.1, wb_bfm and
  wb_intercon 1.4.1. Options for ModelSim, XSim and ISim, which have no flow API, moved
  from `tools:` into flat `flow_options`. Edalize passes an option only to a tool in
  the flow that takes it, so Icarus ignores them.
- **Failures under both:** problems already in the library: files missing upstream
  (iob_eth `sim`, olo_vivado_tutorial 3.0.2 `zybo_z7`, servant 1.0.0 `orangecrab`), a
  dependency conflict (wb_sdram_ctrl r3 `sim`, r4 `sim`, `sim_altsyncram`, `sim_ecp5`)
  and a missing nextpnr chipdb (mor1kx 5.2 `synth`).
- **Not tested:** only setup was run; nothing was compiled, simulated or synthesized.

## Duplicate cores removed

open-logic 4.2.0 to 4.6.0 each shipped `en_cl_fix.core` with the same VLNV,
`open-logic:open-logic:en_cl_fix:2.3.2`. FuseSoC keeps only one core per VLNV and warned
on every load. Only the copy in 4.6.0 is kept now, which is the one FuseSoC used
anyway. It fetches its sources from GitHub, so every release's `olo_fix` still resolves
it.

## Targets not converted

Edalize 0.6.8 has no flow-API implementation of Quartus, ISE, Diamond, ModelSim,
Libero, Radiant or OpenLane, and CAPI=3 has only the flow API. Instead of leaving
these 25 cores on CAPI=2, the rest of each core is converted and the 102 targets that
use those tools are kept as commented-out CAPI=2 blocks headed `# Not converted:`
(`git grep -n 'Not converted'`). Restore them when Edalize gets a flow for the tool.

| Core | Targets not converted |
|---|---|
| `fusesoc_utils/blinky-0`, `blinky-1.0` | 17 each (quartus, ise, diamond) |
| `fusesoc_utils/blinky-1.1` | 31 (also radiant, libero) |
| `serv/servant` 1.0.0, 1.0.2, 1.0.2-r1, 1.1.0 | 1, 4, 4, 8 (quartus, ise, diamond) |
| `open-logic/*/olo_quartus_tutorial` (13 versions) | `de0_cv` (quartus) |
| `i2c/i2c-1.15` | `sky130` (openlane) |
| `pulp-platform.org/axi-0.6` | `sim` (modelsim) |
| `pulp-platform.org/common_cells-1.11.0` | `cdc_2phase_tb`, `cdc_fifo_tb` (modelsim) |
| `SD-card-controller` r2, r3 | `tb` (modelsim) |
| `wb_altera_ddr_wrapper` | `sim` (modelsim) |

## What to expect

- **Tool flags are variables now.** Cores that selected files on `tool_<name>`
  (`tool_icarus`, `tool_quartus`, `tool_verilator`, …) declare a variable of that
  name, and each says how to set it. The converted targets set the ones dependencies
  read, e.g. `vars: {tool_icarus: true}`; your own top level does the same, or pass
  `--var +tool_icarus`. Those targets also set `flags: {tool: …}` for CAPI=2
  dependencies.
- **Unused-variable warning.** 13 Icarus and 3 Verilator builds warn that
  `tool_icarus` or `tool_verilator` is set but no core declares it. The converter sets
  the variable on every target with a flow-API tool, since it cannot know which
  dependencies read it. The warning is harmless.
- **Vivado constraints follow the flow.** `tool_vivado` became `flow == 'vivado'`
  (open-logic `olo_base` and `olo_intf` 4.x, SweRV EL2), so a Vivado top level gets
  the scoped constraints without setting anything.
- **Targets with no flow:** ac97 `synth` and wb_intercon 1.2.2 / 1.2.2-r1 `sim` named
  no tool, so CAPI=2 ran them with `--tool`. They have no `flow:` now and cannot run
  until one is chosen; the cores say so.
- **jtag_vpi (r3–r5) builds no VPI library.** CAPI=3 has no `vpi:`, and the flow API
  ignored it already. The VPI sources are still added to non-Verilator builds. A
  generator that builds the library is still to be written.
- **Generators:** servant uses `icepll`. The converter asked to check the parameters
  of generated cores, which are ordered differently once a tree holds a CAPI=3 core.
  This assumes icepll's generated core declares no parameters; that was not checked.
- **Flattened tool options:** or1ksim_trace (`verilator_options`), wb_intercon
  (`fuse_options`), wb_bfm, wb_sdram_ctrl and blinky `sim` had `tools.<tool>` options
  moved into flat `flow_options`, with a comment where the tool has no flow. Diamond's
  `part` (blinky `ulx3s`) is a comment instead, because Vivado also takes `part`.

## How the diff was kept small

`fusesoc core migrate` re-indents every list to its own style. The conversion ran with
each file's own list indentation, then restored every line that changed only in
spacing, a blank line, or a multi-line flow list the dump folded onto one line. Lines
that only moved (`tools.vivado.part` to `flow_options.part`) keep the author's
spacing. ethmac, with 3-space indentation, was converted by hand. Original comments
are kept; every `# FUSESOC-MIGRATE:` comment was resolved or replaced by an
explanation.

## Running it

With the CAPI=3 FuseSoC installed, from this directory:

```sh
fusesoc --cores-root . run --setup --target=fifo_tb ::fifo:1.3-r1
fusesoc --cores-root . run --setup --target=zybo_z7 open-logic:tutorials:vivado_tutorial:4.7.0
```

CAPI=3 top levels reject the global `--tool`; the target's `flow:` picks the backend,
and flow options go after the core name.
