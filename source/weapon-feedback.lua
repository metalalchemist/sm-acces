-- Native recovery and charge are separate. No timing is inferred from keys.
return function()
 local previous
 local api={}
 function api.describe(s,b)
  if not s.base then return 'Arma no disponible.'end
  local a=s.base;local cap=b(a+0x19C);local stage=b(a+0x1B);local kind=b(a+0x68)
  local names={[0]='Guantes o nudillo',[1]='Espada',[2]='Hacha',[3]='Lanza',[4]='Látigo',[5]='Arco',[6]='Bumerán',[7]='Jabalina'}
  local text=(names[kind] or 'Arma desconocida')..'. '..((kind==0 or kind==1 or kind==3)and 'Alcance sonoro para ataques normales. 'or 'Esta arma aún no tiene previsión sonora de alcance. ')
  text=text..(b(a+0x1ED)==0 and 'Potencia recuperada al 100 %.'or'Potencia recuperándose.')
  if cap==0 then return text..' Habilidad de arma nivel 0: sin carga especial.'end
  if stage>0 then return text..' Carga '..stage..' de '..cap..(stage>=cap and ', máxima. Suelta el ataque para ejecutarla.'or'.')end
  return text..' Carga especial disponible hasta nivel '..cap..'. Mantén el botón de ataque para cargar; suéltalo para ejecutar.'
 end
 function api.tick(s,io)
  if not s.field or not s.base then previous=nil;return end
  local a,b=s.base,io.b
  local current={base=a,map=s.map,weapon=b(a+0x1E4),recovery=b(a+0x1ED),stage=b(a+0x1B),cap=b(a+0x19C)}
  if previous and previous.base==a and previous.map==s.map and previous.weapon==current.weapon then
   if previous.recovery>0 and current.recovery==0 then io.cue('ready',0,0.2)end
   if current.cap>0 and current.stage>previous.stage and current.stage<=current.cap then
    io.cue(current.stage==current.cap and 'charge_max'or'charge_step',0,0.38)
   end
  end
  previous=current
 end
 return api
end
