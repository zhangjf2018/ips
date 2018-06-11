


local resty_rsa = require("resty.rsa")

local cert_path = "/home/xp/cert/bft/"

local MER_PUB_KEY = [[
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBAPFezxtlZzllrl4te8mCmR28jgHRaHXb40sGcRTGGcgWjS9xCB+Brd+x
FAJwNEu+QVk6yd6X6A2za6VMPdgsoDibJLy8y6NHoSN9X1w6W7eCbhHZlMDe/Do+
wQKgyhQT1Uu5w0lXH09zVTSUzK+1ID3QwAGcuZHhEyonfXltBcqTAgMBAAE=
-----END RSA PUBLIC KEY-----
]]


local SER_PRI_KEY = [[
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDeOJgTP8oPPUF/2SInBFVLotfgqUAbwEN4Bk343J+/pkEONAi6
NwgTdXG2jvUEcS/hSYge6ulNAgTqqH7oLlJ2D330HUGN6yqVQ6qrmQcyBKVjp1Z0
WpvSBQGolY8cZ6MrZBtFyRKV0DgOIoJ8y8AL2uGDKrjAl8Hh+h7yMiKCsQIDAQAB
AoGAXQ2PyMe2YelBqzqOTY5H9VMsWLwmxzgcSH9DWUlxb3w706nAWdG/hP5x7oMw
YHrRFOKIqIGvzfpheq2x7qGvD08ubIrMixFyC6ReexT7tvB7yDkpXgY+75EUocoj
TkELhfhFjPTH17mg6AY6D9UJH+TBdg9Sq2WEmRl0+fZlPcECQQDvBzrqlL67N8ry
39VStwvtzsRcxe49QuMmJov03j1AbpkDEmHxHkFM1CrQUMrqKmGGdU5OsGCQoPwu
g3w17j/pAkEA7f/c+s5pW7nDyolWghnSHOUmOjv6hxXh0eWZIufP/b4Zw6/zX0/P
LXqT9B27QV6LWeeMdJeiZdlyCdPBB2V3iQJAS6h2NZovZQMb8hR3aV8XH4a7EMJ1
zl5Fl+XLlw5hROu88wP2jGOPN8pQYu+vyr7vb6fhyXZ6mkzahb6IqmlnQQJBAJEM
7ZsWDfRPZVqdFVI5dmsR5Zh8UZXe6kBIlGpHqeXV5FH1fHhMZdIr8NxI+oU+n+Nt
UZcFi35TZkNDAVQGrTECQQCGOqCWy4WKCMEHd47zTPK4ntf+HeI8s32Uk1ZLKxmh
usWRNieeCzYRFj2IQ/pt8tnUbOqMphV/fTqj/y9kpdnc
-----END RSA PRIVATE KEY-----
]]


local MAX_ENCRYPT_BLOCK = 117
local MAX_DECRYPT_BLOCK = 128

local ns = "agCiO4TNN3mOFYuyGEFO/Q/Nu34emk5dSS1zk7m+tmrSHH+p3z4CSx2LSGsbiVnMKv+0W0UiPZbfKh7vKpplO9xKpk9LVZ6Ys95bKrLwsS4NyMYMdVobca1/SXfA6+zdNouKq//2yBIq/nQ7HEuOTX58a78NeHZSGZE5d8A24aWuqHiejXco4yZ+xqcXSX0Qu/vfyx2na4b6zfjio8puWxPaxljywPUDGRfqPEhx8LIhGxAYUCHOw5Gbxqdiw/8c5UbDlBwti+Feosm6Wtv6pokmSP3GXBKaOkQCoUnUC+n7pEzwdWvGQDZM4Eai+A00wTST1cm7YUS7HPk+pcZlW3wULQM+3A2OysOG6YCKetfAdDNu+oAwPK89gpvesyNyY5mZhQqZyl7mzV/krWTdKgJ6OQUFcuQh0DRyiNI8Bq4aTls7eWc/a8eEhX5+f7OrYSvGLkwHd53vwG1rYBrHQrXRQUadHSoc8IiADAyXjz2LcOz/phA0QSEJCbvfDe4up9hOHQBBC+oFWCgZ93JDLqQv1u1NuHlVrI+qqfxdIXQvjIat4+uFCtArTBnIYKUnZFO/jCV53eJ3+Z8AO1U1Bi6jwZ/zxhZj1RTLcz5ELfuWQl4w4AtIZdarn516bCEm73NDuXSULQeLwtvuU73U6+9NdU4N9uzBRuwhWyg9z7sQMAPLWmcqOyou0UWmsBs8QWXWj3RBE5v+s+eSSxHlq9RtJvHYAKREOjXTelJakzWo8wFMHN7Tmaz20iuvEX2IvyGxway2hUbPowd20aWUQgdL48UolODhIvUUS2qCRwp4HIKAe9U3j0EtsXUZ7uB/OJenpoPJmAEzXP5DGYxqmXwjFeNDTLz0wmpW9jAqbHrLMvHMllf4DIVRhAD2Das5n6ShF5tdGcLdl5Wv4kPJxtj4RfSJzg7jpABeAdf1aR/Q3k1uKWt2ofaj2+ucaygW9jUHwM4+9fz3wbhnvwVDfB0QYiCmZKAYpN/uDdzKaSW81AwY7T6buYczASHsSGO/ALKghnP82f9llVnybY6iBT01OQUvcewjU3eFF7EVYo1bbOCA8+Il76q+kCh2Z6t6tYKRmysDCuKvkxmtQj/WbfDnLziV5kP07Fl2yR9ety1J8zn1fSsATHnQL3pFzgJ0vwUWCG2d4pTloDUIJcCYwGTBMsCtuvQxRhN7xRMzywZgAjKsZH00j3vbonA5F1kw9Bi9lKQWlNo8KMiKanqL9BcaE3dEn2lIW5H9+ksKCYviaWnzfBl3EgAK78sycjcHzka/P9i1o6dTc1R9EMWM9HvafWH8apHyq767upZdOBTBzdJRGKa/ttbeP5bbddU+Blh+ejDymL6WcLocK3kwBg=="
ns = "O2SQjqsoXrlzw33tx9OvvAns7MAanADFBvjCjBokKvp9luLFQshPE85yXjMzEmS2l5kQ2G8zskQKNBrZlTSnSz/cA/4DeLk+KS5paSv20V+R4T/L4U98hU+6Xd7h3+m+UU8uXpTlSoocgYgAX6DWe9MRCZQMCGyN1NiRznWoOHw="
ns = ngx.decode_base64( ns )

local resty_rsa = require "resty.rsa"
local pub, err = resty_rsa:new({ public_key = MER_PUB_KEY })
if not pub then
    ngx.say("new rsa err: ", err)
    return
end
local enc_str = "%7B%22areaid%22%3A%22%22%2C%22areaname%22%3A%22%22%2C%22bankalias%22%3A%22%22%2C%22bankcard%22%3A%226200580200001981863%22%2C%22bankcardtype%22%3A%2201%22%2C%22bankcode%22%3A%22%22%2C%22bankname%22%3A%22%22%2C%22bizno%22%3A%22000100150000598%22%2C%22cardtypecode%22%3A%22%22%2C%22consumemoney%22%3A%22%22%2C%22consumestate%22%3A%22%22%2C%22cvn2%22%3A%22%22%2C%22errcode%22%3A%22%22%2C%22idcard%22%3A%22120106199303281519%22%2C%22idcardtype%22%3A%2201%22%2C%22jobid%22%3A%22%22%2C%22key%22%3A%226bd3799fb5e259b8752ab3408705c4c4d16ebf90%22%2C%22message%22%3A%22%22%2C%22mobile%22%3A%2215313185227%22%2C%22photo%22%3A%22%22%2C%22provincename%22%3A%22%22%2C%22realname%22%3A%22%E8%8B%97%E8%8B%97%22%2C%22requestsn%22%3A%224e295ddcec3f4a5f8e41cf03758b1a61%22%2C%22requesttime%22%3A%221106193917521%22%2C%22responsetime%22%3A%22%22%2C%22validdate%22%3A%22%22%2C%22version%22%3A%22data.bft.client-1.4.0%22%7D"
enc_str = "1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEFABCDE"
local enc_len = #enc_str
ngx.say(enc_len)
local enc_result = ""
local j = 0
while( enc_len - j * MAX_ENCRYPT_BLOCK > 0 )
do
	local enc_tmp = ""
	local start_pos = j * MAX_ENCRYPT_BLOCK + 1
	local end_pos = (j+1) * MAX_ENCRYPT_BLOCK
	if enc_len - j * MAX_ENCRYPT_BLOCK > MAX_ENCRYPT_BLOCK then
		enc_tmp = enc_str:sub( start_pos, end_pos )
	else
		enc_tmp = enc_str:sub( start_pos )
	end
	enc_tmp = pub:encrypt( enc_tmp )
	j = j + 1
	enc_tmp = enc_tmp or ""
	enc_result = enc_result .. enc_tmp
end

ngx.say(ngx.encode_base64( enc_result ))

local priv, err = resty_rsa:new({ private_key = SER_PRI_KEY })
if not priv then
    ngx.say("new rsa err: ", err)
    return
end

local enc_len = #ns
ngx.say(enc_len)
ngx.say("")ngx.say("")
local j = 0
local decrypt_str = ""
local enc_tmp = ""
local dec_tmp = ""

while( enc_len - j * MAX_DECRYPT_BLOCK > 0 )
do
	local pos_start = j * MAX_DECRYPT_BLOCK + 1
	local pos_end = ( j+1 ) * MAX_DECRYPT_BLOCK
	j = j + 1
	enc_tmp = ns:sub( pos_start, pos_end )

	dec_tmp = priv:decrypt( enc_tmp )
	dec_tmp = dec_tmp or ""
	decrypt_str = decrypt_str .. dec_tmp
end

ngx.say(ngx.unescape_uri(decrypt_str))