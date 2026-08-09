# latexmk configuration: LuaLaTeX only, everything built into build/.
$pdf_mode = 4;    # 4 = lualatex
$out_dir  = 'build';
$aux_dir  = 'build';
$bibtex_use = 2;  # run biber automatically; latexmk -C also removes .bbl
@default_files = ('main.tex');

# -shell-escape: required by minted (Pygments runs as a subprocess).
$lualatex = 'lualatex -shell-escape %O -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 %S';

# minted v3 auto-detects the output directory on TeX Live 2024+; MiKTeX needs
# it spelled out. Must match $out_dir above.
$ENV{'TEXMF_OUTPUT_DIRECTORY'} = 'build';

# TeX Live does not auto-create the build/ subdirectories that \include'd
# files write their .aux into (MiKTeX does), so create them up front.
use File::Path qw(make_path);
for my $dir (grep { -d } glob('chapters/*'), 'backmatter') {
    make_path("$out_dir/$dir");
}
