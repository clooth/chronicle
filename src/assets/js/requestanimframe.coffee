(() ->
    lastTime = 0
    vendors = ['ms', 'moz', 'webkit', 'o']
    x = 0
    while x < vendors.length && !window.requestAnimationFrame
        window.requestAnimationFrame = window["#{vendors[x]}RequestAnimationFrame"]
        window.cancelAnimationFrame  = window["#{vendors[x]}CancelAnimationFrame"] ||
                                       window["#{vendors[x]}CancelRequestAnimationFrame"]
        x++

    if not window.requestAnimationFrame
        window.requestAnimationFrame = (callback, element) ->
            currentTime = new Date().getTime()
            timeToCall = Math.max(0, 16 - (currentTime - lastTime))
            id = window.setTimeout () ->
                callback(currentTime + timeToCall)
            , timeToCall
            lastTime = currentTime + timeToCall
            id

    if not window.cancelAnimationFrame
        window.cancelAnimationFrame = (id) ->
            clearTimeout(id)
)()