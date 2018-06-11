

local project = "ips"

local str_find = string.find
local s,e = str_find(package.path, project)
if not s then
	package.path = "../"..project.."/?.lua;;"..package.path
end

local consistent = require("ut.hash")

--[[
consistent.add_server({'t1','t2','t3','t4','t5','t6','t7','t8','t9','t10',
	't11','t12','t13','t14','t15','t16','t17','t18','t19','t20',
	't21','t22','t23','t24','t25','t26','t27','t28','t29','t30',
	't31','t32','t33','t34','t35','t36','t37','t38','t39','t40',
	't41','t42','t43','t44','t45','t46','t47','t48','t49','t50',
	't51','t52','t53','t54','t55','t56','t57','t58','t59','t60',
	't61','t62','t63','t64','t65','t66','t67','t68','t69','t70',
	't71','t72','t73','t74','t75','t76','t77','t78','t79','t80',
	't81','t82','t83','t84','t85','t86','t87','t88','t89','t90',
	't91','t92','t93','t94','t95','t96','t97','t98','t99','t100',});
]]--

consistent.add_server({'t1','t2','t3','t4'});

local a,b = 1,1;
--[[

local sum = {}

for i=1, 10000 do

	local ser = consistent.get_upstream(math.random());
	
	local m = sum[ser] or 0
	sum[ser] = m + 1
 
end

local t1 = sum["t1"] or 0
local t2 = sum["t2"] or 0
]]--

function ch( key,  num_buckets) 
    math.randomseed(key) ;
    local b = -1; --  bucket number before the previous jump
    local j = 0; -- bucket number before the current jump
    while(j<num_buckets)
    	do
        b=j;
        local r=math.random(); --  0<r<1.0
        j = math.floor( (b+1) /r);
   	end
    return b;
end

function main()
		--ngx.say( t1 ..":" ..  t2 ) --5404,4598
	local order = "44030110000120170224201922"
	
	ngx.say("1: ".. consistent.get_target( order ) )
	--ngx.say("1: ".. hash_tool.get_hash_node( order ) )
	
	local order = "44030110000120170222224201923"
	ngx.say("2: "..  consistent.get_target( order ) )
	
	local order = "44030110000120170224201924"
	ngx.say("3: "..  consistent.get_target( order ) )
	
	local order = "44030110000120170224201925"
	ngx.say("4: "..  consistent.get_target( order ) )

	local order = "44030110000120170224201923"
	ngx.say("5: "..  consistent.get_target( order ) )
	
	local order = "44030110000120170224201926"
	ngx.say("6: "..  consistent.get_target( order ) )

	local order = "144030110000120170224201923"
	ngx.say("7: "..  consistent.get_target( order ) )

	local order = "P142030110000120170224201923"
	ngx.say("8: "..  consistent.get_target( order ) )

	local order = "P14203011000012OK0Mms170224201923"
	ngx.say("9: "..  consistent.get_target( order ) )
	
	local order = "P14203019990012OK0Mms170224201929"
	ngx.say("10: "..  consistent.get_target( order ) )

end

main()

