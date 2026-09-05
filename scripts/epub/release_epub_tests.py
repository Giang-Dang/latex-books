"""Focused regression tests for EPUB source preparation and link checks."""

from __future__ import annotations

import contextlib
import io
import tempfile
import unittest
import zipfile
from pathlib import Path

import release_epub


class TablePreparationTests(unittest.TestCase):
    def test_only_real_tables_are_rewritten(self) -> None:
        source = r"""% \multicolumn{bad}{c}{comment}
\newminted[json]{json}{}
\begin{json}
\multicolumn{bad}{c}{captured code}
\end{json}
\begin{tabular}{lll}
\multicolumn{2}{c}{Group} & Other \\
\cmidrule(lr){1-2}
A & B & C \\
\end{tabular}
"""

        prepared = release_epub.prepare_tables(source)

        self.assertIn(r"% \multicolumn{bad}{c}{comment}", prepared)
        self.assertIn(r"\multicolumn{bad}{c}{captured code}", prepared)
        self.assertIn(r"\href{epub-colspan:2}{Group} & & Other", prepared)
        self.assertNotIn(r"\cmidrule(lr){1-2}", prepared)

    def test_nested_and_escaped_braces_survive(self) -> None:
        source = (
            r"\begin{tabular}{lll}"
            r"\multicolumn{2}{c}{A {nested} and \{escaped\}} & C"
            r"\end{tabular}"
        )

        prepared = release_epub.prepare_tables(source)

        self.assertIn(
            r"\href{epub-colspan:2}{A {nested} and \{escaped\}} & & C",
            prepared,
        )


class InternalLinkTests(unittest.TestCase):
    @staticmethod
    def _epub(path: Path, chapter_link: str) -> None:
        with zipfile.ZipFile(path, "w") as archive:
            archive.writestr(
                "EPUB/text/ch001.xhtml",
                '<html><body><a href="%s">target</a></body></html>'
                % chapter_link,
            )
            archive.writestr(
                "EPUB/text/ch002.xhtml",
                '<html><body><div id="fig:target">figure</div></body></html>',
            )

    def test_cross_document_fragment_is_accepted(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            epub = Path(directory) / "valid.epub"
            self._epub(epub, "ch002.xhtml#fig:target")
            with contextlib.redirect_stdout(io.StringIO()):
                release_epub.validate_internal_links(epub)

    def test_missing_fragment_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            epub = Path(directory) / "invalid.epub"
            self._epub(epub, "ch002.xhtml#fig:missing")
            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaisesRegex(SystemExit, "missing fragment"):
                    release_epub.validate_internal_links(epub)


if __name__ == "__main__":
    unittest.main()
