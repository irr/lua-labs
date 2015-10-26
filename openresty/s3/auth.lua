-- http://docs.aws.amazon.com/AmazonS3/latest/API/APIRest.html
-- http://tmont.com/blargh/2014/1/uploading-to-s3-in-bash
--
local AWSAccessKeyId = os.getenv("AWS_ACCESS_KEY_ID")
local AWSSecretAccessKey = os.getenv("AWS_SECRET_ACCESS_KEY")
local Bucket = "irrs3"
local Host = string.format("%s.s3.amazonaws.com", Bucket)
local Key = "s3.txt"

local Now = ngx.cookie_time(ngx.now())
local Request = string.format("GET\n\n\n%s\n/%s/%s", Now, Bucket, Key)
local Digest = ngx.encode_base64(ngx.hmac_sha1(AWSSecretAccessKey, Request))

local curl = string.format("\ncurl -v -H \"Date: %s\" -H \"Authorization: AWS %s:%s\" http://%s/%s", Now, AWSAccessKeyId, Digest, Host, Key)

ngx.say(curl .. ";echo")

local ContentType = "text/plain"

local StringToSign=string.format("PUT\n\n%s\n%s\n/%s/%s", ContentType, Now, Bucket, Key)
local Signature = ngx.encode_base64(ngx.hmac_sha1(AWSSecretAccessKey, StringToSign))

curl = string.format("\ncurl -v -X PUT -T \"%s\" -H \"Date: %s\" -H \"Authorization: AWS %s:%s\" -H \"Host: %s\" -H \"Content-Type: %s\" http://%s/%s", Key, Now, AWSAccessKeyId, Signature, Host, ContentType, Host, Key)

ngx.say(curl .. ";echo")

local StringToSign=string.format("DELETE\n\n\n%s\n/%s/%s", Now, Bucket, Key)
local Signature = ngx.encode_base64(ngx.hmac_sha1(AWSSecretAccessKey, StringToSign))

curl = string.format("\ncurl -v -X DELETE -H \"Date: %s\" -H \"Authorization: AWS %s:%s\" -H \"Host: %s\" http://%s/%s", Now, AWSAccessKeyId, Signature, Host, Host, Key)

ngx.say(curl .. ";echo")

--[[
curl -X PUT -T "${file}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${bucket}.s3.amazonaws.com/${file}

curl -v -H "Date: Mon, 26-Oct-15 15:37:43 GMT" -H "Authorization: AWS ...:...." http://irrs3.s3.amazonaws.com/test;echo

curl -v -X PUT -T "s3.txt" -H "Date: Mon, 26-Oct-15 15:37:43 GMT" -H "Authorization: AWS ...:..." -H "Host: irrs3.s3.amazonaws.com" -H "Content-Type: text/plain" http://irrs3.s3.amazonaws.com/s3.txt;echo

curl -v -X DELETE -H "Date: Mon, 26-Oct-15 15:37:43 GMT" -H "Authorization: AWS ...:..." -H "Host: irrs3.s3.amazonaws.com" http://irrs3.s3.amazonaws.com/s3.txt;echo
--]]

