# EssentialFeed

[![CI](https://github.com/loloa/EssentialFeed/actions/workflows/CI.yml/badge.svg)](https://github.com/loloa/EssentialFeed/actions/workflows/CI.yml)

Insert
    - To empty cache works
    - To non-empty cache overrides previous value
    - Error (if possible to simulate, e.g., no write permission)

- Retrieve
    - Empty cache returns empty (before something is inserted)
    - Empty cache twice returns empty (no side effect)
    - Non-empty cache returns data
    - Non-empty cache twice returns same data (retrieve should have no side-effects)
    - Error (if possible to simulate, e.g., invalid data)
    - Error twice returns same error 

- Delete
    - Empty cache does nothing (cache stays empty and does not fail)
    - Inserted data, leaves cache empty
    - Error (if possible to simulate, e.g., no write permission)

- Side-effects must run serially to avoid race-conditions (deleting the wrong cache... overriding the latest data...)
