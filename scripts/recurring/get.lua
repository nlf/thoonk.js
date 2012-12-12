-- ARGV: name, curtime
local name, curtime = unpack(ARGV);

local r = redis.call('zrange', 'recurring:'..name, 0, 0, 'WITHSCORES');
local lastcheck = redis.call('GET', 'recurring.lastcheck:'..name);
local ratelimit = redis.call('HGET', 'recurring.config:'..name, 'ratelimit');
if(#r == 2) then
    if(r[2] > curtime) then
        return {"NOTYET", false, r[2]};
    elseif(tonumber(curtime) < lastcheck + ratelimit) then
        return {"NOTYET", false, lastcheck + ratelimit};
    else
        local timeout = redis.call('HGET', 'recurring.config:'..name, 'timeout');
        redis.call('ZADD', 'recurring:'..name, curtime + timeout, r[1]);
        redis.call('SET', 'recurring.lastcheck:'..name, curtime);
        return {false, r[1], r[2]};
    end
else
    return {"EMPTY"};
end
