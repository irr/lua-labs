local AWSAccessKeyId = os.getenv("AWS_ACCESS_KEY_ID")
local AWSSecretAccessKey = os.getenv("AWS_SECRET_ACCESS_KEY")
local Bucket = "irrs3"
local Host = string.format("%s.s3.amazonaws.com", Bucket)
local Key = "test"

local Now = ngx.cookie_time(ngx.now())
local Request = string.format("GET\n\n\n%s\n/%s/%s", Now, Bucket, Key)
local Digest = ngx.encode_base64(ngx.hmac_sha1(AWSSecretAccessKey, Request))

ngx.say(string.format("\ncurl -v -H \"Date: %s\" -H \"Authorization: AWS %s:%s\" http://%s/%s\n", Now, AWSAccessKeyId, Digest, Host, Key))

