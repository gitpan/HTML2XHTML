use strict;

use Test::More 'no_plan';

use HTML2XHTML;

my $convert = new HTML2XHTML(file_name => 'try.html');
ok($convert, "1 HTML document successfully converted");

# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------

