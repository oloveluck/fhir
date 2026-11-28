"""The toolkit for asyncio programs (a web server, an async pipeline).

    from fhir_toolkit import AsyncToolkit

    async with AsyncToolkit(workers=4) as fhir:
        outcome = await fhir.validate(resource)
        rows = (await fhir.view("SELECT id FROM Patient", data)).rows

Every method of `Toolkit` is here, as a coroutine with the same arguments and answer. A call runs
in a thread of its own and waits for the toolkit's process without holding the event loop, so the
loop serves other work meanwhile. With `workers=n`, up to n calls are answered at the same time,
each by its own process; more wait their turn.

A call that is cancelled (a client disconnects, `asyncio.wait_for` runs out) stops waiting at once;
the toolkit finishes it and its answer is dropped, so nothing it computed reaches another call.
Give the Toolkit a `timeout` to stop a call itself.
"""
import asyncio
import functools
from typing import Any, Optional, Sequence

from .results import Commit, Stage
from .toolkit import Toolkit

#: the Toolkit's methods that are calls of the toolkit (each is a coroutine here)
CALLS = (
    "version", "guide", "fhirpath", "fhirpath_each", "load", "validate", "validate_each", "decompile", "transform",
    "operation", "compile", "check", "elm", "run", "query", "explain", "fsh", "cql", "view", "sql", "search",
    "expand", "validate_code", "lookup", "subsumes", "translate", "stage", "write",
)


class AsyncToolkit:
    """`Toolkit` for asyncio: the same methods, each awaited. See `Toolkit` for the arguments.

    `sync` is the Toolkit underneath, for what needs no waiting (`Project`, a `Table`'s methods).
    """

    def __init__(self, fhir_version: str = "4.0.1", *, packages: Sequence[str] = (),
                 command: Optional[Sequence[str]] = None, start: bool = True, timeout: Optional[float] = None,
                 workers: int = 1):
        self.sync = Toolkit(fhir_version, packages=packages, command=command, start=start, timeout=timeout,
                            workers=workers)

    def __repr__(self) -> str:
        return "Async" + repr(self.sync)

    async def commit(self, stage: Stage, reason: Optional[str] = None, *, agent: Optional[str] = None) -> Commit:
        """A stage's commit (`stage.commit(reason)`), awaited."""
        return await asyncio.to_thread(stage.commit, reason, agent=agent)

    async def aclose(self) -> None:
        """Stop the toolkit's processes."""
        await asyncio.to_thread(self.sync.close)

    def close(self) -> None:
        self.sync.close()

    async def __aenter__(self) -> "AsyncToolkit":
        return self

    async def __aexit__(self, *exc: Any) -> None:
        await self.aclose()


def _coroutine(name: str):
    method = getattr(Toolkit, name)

    @functools.wraps(method)
    async def call(self: AsyncToolkit, *args: Any, **kwargs: Any) -> Any:
        return await asyncio.to_thread(getattr(self.sync, name), *args, **kwargs)
    return call


for _name in CALLS:
    setattr(AsyncToolkit, _name, _coroutine(_name))
