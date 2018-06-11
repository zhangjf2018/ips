
function gen_sign( txml, key)
	local tsort = {}
    local index = 0
    for k, v in pairs( txml ) do
        if k ~= "sign" and v ~= nil and v ~= "" then
            index = index + 1
            tsort[ index ] = k .. "=" .. v
        end
    end

    table.sort( tsort )

    local tc_str = table.concat( tsort, "&" )
    local suffix = "&key="
		suffix = suffix .. key
    local mstr = tc_str .. suffix

    ngx.say("sign str: " .. mstr)

    local sign = ngx.md5( mstr )
    sign = string.upper( sign )

	return sign
end

local tb = {
	version = "123",

	sign = "jksdfksdf",
	nonce = "13123",
	mid = "18293819238",
	tid = "123123",
}

local s = gen_sign(tb, "123")
ngx.say( s )

