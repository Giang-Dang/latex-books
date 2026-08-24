# latexmk configuration: LuaLaTeX only, everything built into build/.
$pdf_mode = 4;    # 4 = lualatex
$out_dir  = 'build';
$aux_dir  = 'build';
$bibtex_use = 2;  # run biber automatically; latexmk -C also removes .bbl
@default_files = ('main.tex');

$lualatex = 'lualatex %O -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 %S';

# TeX Live does not auto-create the build/ subdirectories that \include'd
# files write their .aux into (MiKTeX does), so create them up front.
use File::Path qw(make_path);
for my $dir (grep { -d } glob('chapters/*'), 'backmatter') {
    make_path("$out_dir/$dir");
}
