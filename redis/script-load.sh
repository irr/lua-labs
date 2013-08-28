#!/bin/bash
redis-cli script load "$(cat script-bayes.lua)"
redis-cli script load "$(cat script-learn.lua)"
redis-cli script load "$(cat script-query.lua)"