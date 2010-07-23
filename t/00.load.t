use Test::More tests => 36;
use Test::Carp;

BEGIN {
    use_ok( 'Module::Want' );
}

diag( "Testing Module::Want $Module::Want::VERSION" );

ok(defined &have_mod, 'imports have_mod() ok');

ok(have_mod('Module::Want'), 'true on already loaded module');
ok(have_mod('Module::Want'), 'true on already loaded module');

ok(!have_mod('lkadjnvlkand::lvknadkjcnakjdnvjka'), 'false on unloadable module');
ok(!have_mod('lkadjnvlkand::lvknadkjcnakjdnvjka'), 'false on unloadable module');

does_carp_that_matches(
    sub { ok(!have_mod('1invalid::ns'), 'false on invalid NS') },
    qr/Invalid Namespace/,
);

for my $ns qw( _what Acme Acme::XYZ Acme::ABC::DEF::X::Y::Z Acme::XYZ Acme'ABC::DEF::X::Y::Z Acme::ABC::DEF::X::Y'Z Acme::ABC::DEF'X::Y::Z Acme'ABC'DEF'X'Y'Z ) {
    ok(Module::Want::is_ns($ns), "$ns is an NS");
}

ok(!Module::Want::is_ns('1Acme'), "staring number is not an NS");
ok(!Module::Want::is_ns(' Acme'), "space is not an NS");

ok(Module::Want::get_clean_ns(" \n  You::Can't \n") eq 'You::Can::t', 'get_clean_ns()');

ok(Module::Want::get_inc_key('_what') eq '_what.pm', 'single level');
ok(Module::Want::get_inc_key('Acme') eq 'Acme.pm', 'single level');
ok(Module::Want::get_inc_key('Acme::XYZ') eq 'Acme/XYZ.pm', 'two level');
ok(Module::Want::get_inc_key('Acme::ABC::DEF::X::Y::Z') eq 'Acme/ABC/DEF/X/Y/Z.pm', 'multi level');
ok(Module::Want::get_inc_key('Acme::XYZ') eq 'Acme/XYZ.pm', 'two level apaost');
ok(Module::Want::get_inc_key('Acme\'ABC::DEF::X::Y::Z') eq 'Acme/ABC/DEF/X/Y/Z.pm', 'multi level apost first');
ok(Module::Want::get_inc_key('Acme::ABC::DEF::X::Y\'Z') eq 'Acme/ABC/DEF/X/Y/Z.pm', 'multi level apost last');
ok(Module::Want::get_inc_key('Acme::ABC::DEF\'X::Y::Z') eq 'Acme/ABC/DEF/X/Y/Z.pm', 'multi level apost middle');
ok(Module::Want::get_inc_key('Acme\'ABC\'DEF\'X\'Y\'Z') eq 'Acme/ABC/DEF/X/Y/Z.pm', 'multi level apost all');

Module::Want->import('get_inc_key', 'is_ns');
ok(defined &get_inc_key, 'can import get_inc_key() ok');
ok(defined &is_ns, 'can import is_ns() ok');

SKIP: {
    skip 'We are not in dev testing mode', 5 if !defined $Module::Want::DevTesting;
    
    is_deeply(
        [ Module::Want::_get_debugs_refs() ],
        [
           {
               'Module::Want' => 1,
               'lkadjnvlkand::lvknadkjcnakjdnvjka' => 0,
           },
           {
               'Module::Want' => 1,
               'lkadjnvlkand::lvknadkjcnakjdnvjka' => 1,
           },
        ],
        'cache and tries are as expected'
    );
    
    ok(have_mod('Module::Want',1), 'true on already loaded module');
    ok(!have_mod('lkadjnvlkand::lvknadkjcnakjdnvjka',1), 'false on unloadable module');
    
    is_deeply(
        [ Module::Want::_get_debugs_refs() ],
        [
           {
               'Module::Want' => 1,
               'lkadjnvlkand::lvknadkjcnakjdnvjka' => 0,
           },
           {
               'Module::Want' => 2,
               'lkadjnvlkand::lvknadkjcnakjdnvjka' => 2,
           },
        ],
        'cache and tries are as expected'
    );
    
    Module::Want->import("kcskcsm","get_inc_key","have_mod","qsdch","is_ns");
    is_deeply(
        [ Module::Want::_get_debugs_refs() ],
        [
           {
               'Module::Want' => 1,
               'lkadjnvlkand::lvknadkjcnakjdnvjka' => 0,
               'kcskcsm' => 0,
               'qsdch' => 0,
           },
           {
               'Module::Want' => 2,
               'lkadjnvlkand::lvknadkjcnakjdnvjka' => 2,
               'kcskcsm' => 1,
               'qsdch' => 1,
           },
        ],
        'import(X,Y,Z) calls have_mod(NAME) and does not try to import functions'
    );
    
};