(() ->
    logo = $ '#logo'
    unless logo.length > 0
        return

    logo.css  'opacity', 1.0
    logo.data 'blink',   false

    updateLogo = () ->
        opacity = parseFloat(logo.css('opacity')).toFixed(2)
        opacity = parseFloat(opacity)

        if logo.data().blink == true
            opacity += 0.02
        else
            opacity -= 0.02

        if opacity >= 1.00
            logo.data 'blink', false
            opacity = 1.00
        else if opacity <= 0.2
            logo.data 'blink', true
            opacity = 0.2

        opacity = opacity.toFixed(2)

        requestAnimationFrame updateLogo
        logo.css 'opacity', opacity
    updateLogo()
)()