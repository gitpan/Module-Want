use Test::More tests => 12;
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

SKIP: {
    skip 'We are not in dev testing mode', 4 if !defined $Module::Want::DevTesting;
    
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
};