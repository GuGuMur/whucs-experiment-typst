#!/usr/bin/env python3
"""Compile regression fixtures with Typst; requires Poppler's pdftotext."""
from pathlib import Path
import json
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class TemplateRegression(unittest.TestCase):
    def compile(self, body, options=""):
        with tempfile.TemporaryDirectory(prefix=".template-check-", dir=ROOT) as tmp:
            tmp = Path(tmp)
            source = tmp / "check.typ"
            source.write_text(
                '#import "../lib.typ": *\n'
                f'#show: report.with({options})\n' + body,
                encoding="utf-8",
            )
            result = subprocess.run(
                ["typst", "compile", "--root", str(ROOT), str(source)],
                capture_output=True, text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn("warning:", result.stderr)
            return subprocess.check_output(
                ["pdftotext", "-layout", str(source.with_suffix(".pdf")), "-"],
                text=True,
            )

    def test_unnumbered_deep_heading_before_numbered_chapters(self):
        # Previously this tried to slice a shorter heading counter and failed.
        text = self.compile('''
#toc(depth: 3)
#heading(level: 3, numbering: none)[DEEP-UNNUMBERED]
CONTENT-AFTER-HEADING
''')
        self.assertIn("DEEP-UNNUMBERED", text)
        self.assertIn("CONTENT-AFTER-HEADING", text)

    def test_numbering_and_references_are_independent_and_reset(self):
        text = self.compile('''
#main-matter[
= First
#code-listing("assign a = b;", caption: [FIRST-CODE]) <first-code>
#figure(rect(width: 1cm, height: 1cm), caption: [FIRST-IMAGE]) <first-image>
#figure(table(columns: 1, [cell]), kind: table, caption: [FIRST-TABLE]) <first-table>
$ x = y $ <first-equation>
#code-listing("assign c = d;", caption: [SECOND-CODE]) <second-code>
REF-A @first-code; REF-B @second-code; REF-I @first-image;
REF-T @first-table; REF-E @first-equation.
= Second
#code-listing("assign e = f;", caption: [RESET-CODE]) <reset-code>
REF-C @reset-code.
]
''')
        for expected in (
            r"代码\s+1\.1\s+FIRST-CODE", r"代码\s+1\.2\s+SECOND-CODE",
            r"图\s+1\.1\s+FIRST-IMAGE", r"表\s+1\.1\s+FIRST-TABLE",
            r"代码\s+2\.1\s+RESET-CODE", r"REF-A\s+代码\s+1\.1",
            r"REF-B\s+代码\s+1\.2", r"REF-C\s+代码\s+2\.1",
            r"REF-E\s+\(1\.1\)",
        ):
            self.assertRegex(text, expected)

    def test_long_listing_continues_across_pages_with_line_numbers(self):
        lines = [f"wire signal_{i:03d};" for i in range(1, 181)]
        # Include one long line to exercise wrapping within the code column.
        lines[89] += " // " + "wrapped comment " * 18 + "WRAP-END"
        for caption in (False, True):
            with self.subTest(caption=caption):
                arg = ", caption: [LONG-LISTING]" if caption else ""
                text = self.compile(
                    '= Listing\n#code-listing('
                    + json.dumps("\n".join(lines)) + arg + ')\n'
                )
                pages = [p for p in text.split("\f") if p.strip()]
                self.assertGreaterEqual(len(pages), 3)
                for i in range(1, 181):
                    self.assertRegex(text, rf"\b{i}\s+wire signal_{i:03d};")
                self.assertIn("WRAP-END", text)
                self.assertIn("signal_001", pages[0])
                self.assertIn("signal_180", pages[-1])

    def test_heading_stays_with_following_content(self):
        text = self.compile('''
#set page(height: 10cm, width: 14cm, margin: 1cm)
= Chapter
#v(4cm)
== KEEP-HEADING
KEEP-CONTENT
''', options="heading-pagebreak: false, par-spacing: auto")
        pages = [p for p in text.split("\f") if p.strip()]
        heading_page = next(p for p in pages if "KEEP-HEADING" in p)
        self.assertIn("KEEP-CONTENT", heading_page)

    def test_code_block_languages_labels_and_font_overrides(self):
        text = self.compile('''
#code-block("echo TERMINAL", label: none)
#code-block("puts SCRIPT", lang: "tcl")
#code-block("assign ready = 1;", lang: "verilog", label: [CUSTOM-LABEL])
#code-block("PLAIN-TEXT", lang: "text", breakable: true,
  fonts: (mono: ("DejaVu Sans Mono",)))
''')
        for expected in ("TERMINAL", "SCRIPT", "CUSTOM-LABEL", "PLAIN-TEXT"):
            self.assertIn(expected, text)
        self.assertNotIn("bash", text)


if __name__ == "__main__":
    for command in ("typst", "pdftotext"):
        if not shutil.which(command):
            raise SystemExit(f"Required command not found: {command}")
    unittest.main()
