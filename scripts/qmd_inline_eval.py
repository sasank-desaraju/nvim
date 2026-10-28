#!/usr/bin/env python3
"""Evaluate inline `{python} expr` spans of a .qmd the way Quarto would.

Runs the ```{python}``` chunks in order in one namespace (cwd = the qmd's
directory), then evaluates each inline expression. Prints JSON:
  {"items": [{"line", "col_start", "col_end", "value" | "error"}],
   "chunk_errors": [{"line", "error"}], "skipped_chunks": [line...], "elapsed": s}
line is 0-based, cols are 0-based UTF-8 byte offsets (end exclusive), as Neovim expects.
"""
import contextlib, io, json, os, re, signal, sys, time

CHUNK_TIMEOUT = 60     # s per chunk
INLINE_TIMEOUT = 10    # s per inline expression
HEAVY = re.compile(
    r"matplotlib|pyplot|\bplt\.|seaborn|plotly|altair|bokeh|savefig|\.show\(\)"
    r"|#\|\s*(label:\s*fig-|fig-cap)"
)
CHUNK_START = re.compile(r"^\s*```+\s*\{python[^}]*\}")
CHUNK_END = re.compile(r"^\s*```+\s*$")
INLINE = re.compile(r"`\{python\}\s*([^`]*)`")


class Timeout(Exception):
    pass


def _alarm(signum, frame):
    raise Timeout("timed out")


def short(e):
    msg = f"{type(e).__name__}: {e}"
    return msg.splitlines()[0][:200] if msg else type(e).__name__


def main(path):
    t0 = time.time()
    path = os.path.abspath(path)
    qdir = os.path.dirname(path)
    os.chdir(qdir)
    if qdir not in sys.path:
        sys.path.insert(0, qdir)
    os.environ["MPLBACKEND"] = "Agg"
    signal.signal(signal.SIGALRM, _alarm)

    with open(path, encoding="utf-8") as f:
        lines = f.read().split("\n")

    chunks, inline_lines = [], []
    i = 0
    while i < len(lines):
        if CHUNK_START.match(lines[i]):
            start, body = i, []
            i += 1
            while i < len(lines) and not CHUNK_END.match(lines[i]):
                body.append(lines[i])
                i += 1
            chunks.append((start, "\n".join(body)))
        else:
            inline_lines.append(i)
        i += 1

    ns = {"__name__": "__main__"}
    chunk_errors, skipped = [], []
    sink = io.StringIO()
    for start, code in chunks:
        if re.search(r"#\|\s*eval:\s*false", code) or HEAVY.search(code):
            skipped.append(start)
            continue
        try:
            signal.alarm(CHUNK_TIMEOUT)
            with contextlib.redirect_stdout(sink), contextlib.redirect_stderr(sink):
                exec(compile(code, f"<chunk line {start + 1}>", "exec"), ns)
        except BaseException as e:  # noqa: BLE001 - keep going, record it
            if isinstance(e, KeyboardInterrupt):
                raise
            chunk_errors.append({"line": start, "error": short(e)})
        finally:
            signal.alarm(0)
        sink.seek(0); sink.truncate()

    items = []
    for ln in inline_lines:
        text = lines[ln]
        for m in INLINE.finditer(text):
            item = {
                "line": ln,
                "col_start": len(text[: m.start()].encode("utf-8")),
                "col_end": len(text[: m.end()].encode("utf-8")),
            }
            try:
                signal.alarm(INLINE_TIMEOUT)
                with contextlib.redirect_stdout(sink), contextlib.redirect_stderr(sink):
                    item["value"] = str(eval(m.group(1), ns))
            except BaseException as e:  # noqa: BLE001
                if isinstance(e, KeyboardInterrupt):
                    raise
                item["error"] = short(e)
            finally:
                signal.alarm(0)
            items.append(item)

    json.dump({"items": items, "chunk_errors": chunk_errors, "skipped_chunks": skipped,
               "elapsed": round(time.time() - t0, 2)}, sys.__stdout__)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: qmd_inline_eval.py FILE.qmd")
    main(sys.argv[1])
