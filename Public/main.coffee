dropSettings =
    greedy:true
    hoverClass: "ui-state-hover"
    handle:'.handle'
    drop:(e)->
      console.log @,e
      $(@).append $(e.originalEvent.target||e.target).closest('.element').detach().removeAttr('style')[0].outerHTML

$('.editor').sortable()
$('div.item').click ->$(@).children('.label')[0].click()
$('div.item .label').click (e)->
  e.stopPropagation()
  $('.editor').append $('<'+($(@).attr('element')||'div')+'>').
  addClass(@innerHTML.toLowerCase()).addClass('element').addClass('dialog').html($('<div>').addClass('content').
  attr('contenteditable','contenteditable').droppable(dropSettings).html $('<'+($(@).attr('element')||@innerHTML.
  toLowerCase())+' contenteditable>')).attr('param',($(@).attr('param')&&prompt('data'))).
  append($('.editControls').clone().removeClass('template')[0].outerHTML).prepend(@innerHTML).parent().sortable().end()


$('.editor').bind 'DOMSubtreeModified', ->
  $('.preview').html $($('.editor').clone()).find('*').end().html()
  Object.keys(components).map (key, index)->
    $('.preview').find('div.'+key).map ->
      $(@).replaceWith '<'+key+' {'+$(@).attr('param')+'}>'+$(@).children('.content').html()+'</'+key+'>'
    $('.preview '+key).map (index, element)->
      $(element).replaceWith components[key]['content'](element, $(element).html(), reval element)
  $('.preview').find('.element').map (index, value)->$(value).replaceWith $(value).children('.content').children().removeAttr('contenteditable')
  $('.delete paper-ripple').unbind().click ->console.log 'hi',$(@).closest('.element').remove()
  $('.data').unbind().click (e)->$(@).closest('.element').attr('param',prompt('Data '+$(@).closest('.element').attr('param')))
  $('.edit').unbind().click ->$(@).closest('.element').children('.content').children()[0].focus()


reval = (element)->if element&&($(element)[0]||{}).nodeName!='BODY' then (new Function('return '+getExpression element)).bind(reval $(element).parent()[0])() else {}
getData = (data,passedData)->(data.match(/{{([^}]*)}}/g)||[]).map (matched)->data.replace matched,new Function('return '+matched.replace(/[{}"]/g,'')).bind(passedData)()
getExpression = (element)->($(element)[0].outerHTML.match(/{.*?}/)||[''])[0].replace(/[{}"]/g,'')
components =
  if:
    content:(element, content, data)->if data then content else ''
  each:
    content:(element, content, data)->(data||[]).map((value, index)->getData(content, value)[0]).join('')
  filter:
    content:(element, content, data)->((data||[]).map (value, index)->value&&content||'').join('')
  template:
    content:(element, content, data)->$('#'+data).html()
