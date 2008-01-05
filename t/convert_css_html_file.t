use strict;

use Test::More 'no_plan';

use lib 'blib/lib/HTML2XHTML/';  
use HTML2XHTML;

my $convert = new HTML2XHTML(encoding => 'UTF-8', file_name => 't/sample/try.css,t/sample/try.html', doctype=>'Strict', direction=>'LTR', lang=>'en');
ok($convert, "1 HTML document converted.\n1 CSS document converted.");

# ----------------------------------------------------------------
;1;
# ----