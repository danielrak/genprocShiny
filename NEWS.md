# genprocShiny 0.0.0.9000

## Development

- The execution engine is now the `genproc` package (>= 0.2.0). The internal copies of `genproc()`, `add_trycatch_logrow()`, `rename_function_params()`, `from_example_to_function()` and `from_function_to_mask()` are removed.
- Execution is launched from an event with an explicit run lifecycle (`idle`, `ready`, `running`, `done`, `error`, `stale`), non-blocking by default, with optional bounded parallel workers.
- Results are the in-memory `genproc_result`: status, overview, log, failed cases with tracebacks, summary and reproducibility metadata. Process labels and log directories are gone.
- User code parsing and evaluation is centralised in one helper with clearer error messages.
- Module tests are behavioural and include runs against the real `genproc` API.
- Demonstration-ready PoC product: mask, function, execution and results features. Minimal UI and UX, to be refined.
