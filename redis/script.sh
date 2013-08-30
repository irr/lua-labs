redis-cli script load "$(cat script-bayes.lua)"
redis-cli script load "$(cat script-learn.lua)"
redis-cli script load "$(cat script-query.lua)"

redis-cli evalsha 9299c9d872da1c84c14bd5941a54812c700e02dc 1 bayes good bad neutral
redis-cli evalsha 426572946e8d0987c8ccdc079d5a30bc453366cb 2 bayes good tall handsome rich
redis-cli evalsha 426572946e8d0987c8ccdc079d5a30bc453366cb 2 bayes bad bald poor ugly bitch
redis-cli evalsha 426572946e8d0987c8ccdc079d5a30bc453366cb 2 bayes neutral none nothing maybe
redis-cli evalsha 9a3c08ac7c1f25af6dd3d75b0a5035f7bf362d02 1 bayes tall poor rich dummy nothing
