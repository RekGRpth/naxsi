#vi:filetype=perl

use lib 'lib';
use Test::Nginx::Socket;

plan tests => repeat_each(2) * blocks();
no_root_location();
no_long_string();
$ENV{TEST_NGINX_SERVROOT} = server_root();
run_tests();
__DATA__
=== TEST0 - Simple id:11 block
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11 "mz:$URL:/yolo|BODY";
}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

RANDOMTHINGS
"
--- error_code: 412
=== TEST1 - Simple id:11 allow
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11 "mz:$URL:/|BODY";
}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

RANDOMTHINGS
"
--- error_code: 200
=== TEST2 - Simple id:11 allow + simple drop rule
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
MainRule "id:4241" "s:DROP" "str:RANDOMTHINGS" "mz:RAW_BODY";
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11 "mz:$URL:/|BODY";
}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

RANDOMTHINGS
"
--- error_code: 412
=== TEST3 - Simple id:11 allow + simple drop rule + WL raw_body rule
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
MainRule id:4241 s:DROP str:RANDOMTHINGS mz:RAW_BODY;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11 "mz:$URL:/|BODY";
	 BasicRule wl:4241 "mz:$URL:/|BODY";
}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

RANDOMTHINGS
"
--- error_code: 200
=== TEST4 - Simple id:11 allow + simple drop rule + fail WL raw_body rule
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
MainRule id:4241 s:DROP str:RANDOMTHINGS mz:RAW_BODY;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11 "mz:$URL:/|BODY";
	 BasicRule wl:4241 "mz:$URL:/rata|BODY";
}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

RANDOMTHINGS
"
--- error_code: 412
=== TEST5 - Simple id:11 allow + simple drop rule + null-bytes in body
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
MainRule id:4241 s:DROP str:RANDOMTHINGS mz:RAW_BODY;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11 "mz:$URL:/|BODY";
	 BasicRule wl:4241 "mz:$URL:/rata|BODY";
}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

%00RAND B BOMTHINGS%00
"
--- error_code: 200
=== TEST6 - Simple id:11 allow + simple drop rule + null-bytes in body
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
MainRule id:4241 s:DROP str:RANDOMTHINGS mz:RAW_BODY;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11 "mz:$URL:/|BODY";
}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

%00XXRAND B BRANDOMTHINGS%00
"
--- error_code: 412
=== TEST7 - Testing raw bytes match
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
#body was like perl -e 'print "\x02\x02\x00\x00\x02"x42 . "\x01\x02\x03\x04"'
MainRule id:4241 s:DROP "rx:\x01\x02\x03\x04"  mz:RAW_BODY;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
         error_page 400 = $uri;
	 BasicRule wl:11 "mz:$URL:/|BODY";
}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request
POST /

                                                                                    
--- error_code: 412
=== TEST8 - Simple id:11 allow + simple drop rule + fail WL raw_body rule (local rule)
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11 "mz:$URL:/|BODY";
	 BasicRule wl:4241 "mz:$URL:/rata|BODY";
	 BasicRule id:4241 s:DROP str:RANDOMTHINGS mz:RAW_BODY;

}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

RANDOMTHINGS
"
--- error_code: 412
=== TEST8.1 - Simple id:11 allow + simple drop rule + fail WL raw_body rule (local rule)
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11 "mz:$URL:/|BODY";
	 BasicRule wl:4241 "mz:$URL:/|BODY";
	 BasicRule id:4241 s:DROP str:RANDOMTHINGS mz:RAW_BODY;

}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

RANDOMTHINGS
"
--- error_code: 200

=== TEST8.2 - Simple id:11 allow + empty body
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11,16 "mz:$URL:/|BODY";
	 BasicRule wl:4241 "mz:$URL:/|BODY";
	 BasicRule id:4241 s:DROP str:RANDOMTHINGS mz:RAW_BODY;

}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

"
--- error_code: 200

=== TEST8.3 - Simple id:11 allow + empty body
--- main_config
load_module /etc/nginx/modules/ngx_http_naxsi_module.so;
--- http_config
include /etc/nginx/naxsi_core.rules;
--- config
location / {
         SecRulesEnabled;
         DeniedUrl "/RequestDenied";
         CheckRule "$SQL >= 8" BLOCK;
         CheckRule "$RFI >= 8" BLOCK;
         CheckRule "$TRAVERSAL >= 4" BLOCK;
         CheckRule "$XSS >= 8" BLOCK;
         root $TEST_NGINX_SERVROOT/html/;
         index index.html index.htm;
         error_page 405 = $uri;
	 BasicRule wl:11,16 "mz:$URL:/|BODY";
	 BasicRule wl:4241 "mz:BODY";
	 BasicRule id:4241 s:DROP str:RANDOMTHINGS mz:RAW_BODY;

}
location /RequestDenied {
         return 412;
}
--- more_headers
Content-Type: RAFARAFA
--- request eval
use URI::Escape;
"POST /

"
--- error_code: 200

