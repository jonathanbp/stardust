#!/usr/bin/env coffee

readline  = require 'readline'
fs        = require 'fs'
q         = require 'q'

tree = {
  converted: true
  name: 'root'
  "hits": 1
  "totalms": 0
  "avg": 0
  children: []
}

updateTree = (trace) ->
  currentBranch = tree
  while invoke = trace.pop()
    node = currentBranch.children.find (n) -> n.name is invoke
    if node then node["hits"]++
    else
      node =
        name: invoke
        "hits": 1
        "totalms": 0
        "avg": 0
        children: []
      currentBranch.children.push node
    currentBranch = node

fs.readdir(
  process.argv[2],
  (err, files) ->


    promises = for file in files
      do (file) ->

        deferred = q.defer()

        parser =
          trace: []
        
        rl = readline.createInterface({
          input: fs.createReadStream("#{process.argv[2]}/#{file}")
        })
    
        # line by line
        rl.on(
          'line',
          (line) ->
            if /^\s+at.*/.test line
              parser.trace.push /^\s+at\s([^(]+).*/.exec(line)[1]
            else if line.trim() is ""
              updateTree parser.trace
              # reset parser
              parser.trace = []
        )

        rl.on('close', -> deferred.resolve())

        deferred.promise

    q.allSettled(promises).then -> console.log JSON.stringify(tree)
)
    
