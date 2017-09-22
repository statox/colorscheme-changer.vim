if exists('g:colorschemeChangerLoaded') || &cp || version < 700
    finish
endif
let g:colorschemeChangerLoaded = 1

" Define the hours which triggers the daily colorscheme
let s:dayTime = [9, 30, 0]
if exists('g:dayTime')
    let s:dayTime = g:dayTime
endif

" Define the hours which triggers the nightly colorscheme
let s:nightTime = [18, 30, 0]
if exists('g:nightTime')
    let s:nightTime = g:nightTime
endif

" Define the colorscheme used by day
let s:colorschemeDay = 'blue'
if exists('g:colorschemeDay')
    let s:colorschemeDay = g:colorschemeDay
endif

" Define the colorscheme used by night
let s:colorschemeNight = 'darkblue'
if exists('g:colorschemeNight')
    let s:colorschemeNight = g:colorschemeNight
endif

" Convert a time as HH:MM:SS to the number of milliseconds from
" the beginning of the day 00:00:00
function! s:ToMilliseconds(H, M, S)
    return (a:H * 3600 + a:M * 60 + a:S ) * 1000
endfunction

" Return the number of milliseconds beetwen two hours
" Handles the case of a target hour the next day.
" Both hours should be lists composed of three elements: hours, minutes, seconds.
" Eg 11:20:45 pm = [23, 20, 45]
"    09:00:00 am = [9, 0, 0]
function! s:TimeDiff(current, target)
    let targetMilli   = s:ToMilliseconds(a:target[0], a:target[1], a:target[2])
    let currentMilli  = s:ToMilliseconds(a:current[0], a:current[1], a:current[2])
    let nextDay       = targetMilli > currentMilli ? 0 : (24 * 3600 * 1000)

    return nextDay + ( targetMilli - currentMilli )
endfunction

" Check if the current hour is between s:dayTime and s:nighTime
function! s:IsDayTime()
    let current  = s:ToMilliseconds(strftime('%H') ,  strftime('%M') ,  strftime('%S'))
    let day      = s:ToMilliseconds(s:dayTime[0]   ,  s:dayTime[1]   ,  s:dayTime[2])
    let night    = s:ToMilliseconds(s:nightTime[0] ,  s:nightTime[1] ,  s:nightTime[2])

    return current > day && current < night
endfunction

" According to the current time and the nighttime, set the colorscheme and create
" a trigger for the job which will change the colorscheme
function! ScheduleNewColorscheme(timer)
    " Define colorscheme and next time depending on time of day
    if s:IsDayTime()
        let newColorscheme = s:colorschemeDay
        let targetDate = s:nightTime
    else
        let newColorscheme =s:colorschemeNight
        let targetDate = s:dayTime
    endif

    " Set new colorschme
    echom 'setting colorscheme ' . newColorscheme . ' at ' . strftime('%H:%M')
    execute 'colorscheme ' . newColorscheme

    let currentDate = [strftime('%H'), strftime('%M'), strftime('%S')]
    let startDelay = s:TimeDiff(currentDate, targetDate)

    " Create the trigger for the next change
    call timer_start(startDelay, 'ScheduleNewColorscheme', {}) 
endfunction

" When sourcing your vimrc set the colorscheme immediately
call timer_start(0, 'ScheduleNewColorscheme', {}) 
