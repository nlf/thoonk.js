--name, config
local name, config, curtime = unpack(ARGV);
local config = cjson.decode(config);

redis.call('SET', 'recurring.lastcheck:'..name, curtime);
for key, value in pairs(config) do
    redis.call('HSET', 'recurring.config:'..name, key, value);
end
if redis.call('SADD', 'recurrings', name) ~= 0 then
    return {false};
end
return {"Recurring already exists"};
