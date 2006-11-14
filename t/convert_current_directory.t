use strict;

use Test::More 'no_plan';

use HTML2XHTML;

my $convert = new HTML2XHTML(dir => 'current');
ok($convert, "1 HTML document converted.\n1 CSS document converted.");

# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------
