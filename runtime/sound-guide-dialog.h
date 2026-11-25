// A native modal dialog keeps emulation stopped while Windows handles NVDA
// and keyboard navigation. The audio worker continues; it never calls Lua.
static void(__cdecl*getField)(lua_State*,int,const char*);
static void(__cdecl*rawGetI)(lua_State*,int,int);
static void(__cdecl*setTop)(lua_State*,int);
static size_t(__cdecl*objectLength)(lua_State*,int);
static void(__cdecl*checkType)(lua_State*,int,int);
struct GuideEntry { int sound; float volume,pan; std::wstring label; };
struct GuideDialog { std::vector<GuideEntry> entries; HWND list=nullptr; };
static std::wstring guideWide(const char* text,size_t length) {
 int n=MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,text,static_cast<int>(length),nullptr,0);
 std::wstring result(n,L'\0');
 if(n)MultiByteToWideChar(CP_UTF8,0,text,static_cast<int>(length),result.data(),n);
 return result;
}
static INT_PTR CALLBACK guideProc(HWND window,UINT message,WPARAM wp,LPARAM lp) {
 auto* guide=reinterpret_cast<GuideDialog*>(GetWindowLongPtrW(window,DWLP_USER));
 if(message==WM_INITDIALOG) {
  guide=reinterpret_cast<GuideDialog*>(lp);SetWindowLongPtrW(window,DWLP_USER,lp);
  SetWindowTextW(window,L"Aprender los sonidos de Secret of Mana");
  RECT rect;GetClientRect(window,&rect);int width=rect.right,height=rect.bottom;
  auto control=[&](DWORD style,const wchar_t* type,const wchar_t* text,int x,int y,int w,int h,int id) {
   HWND child=CreateWindowExW(0,type,text,WS_CHILD|WS_VISIBLE|style,x,y,w,h,window,
    reinterpret_cast<HMENU>(static_cast<INT_PTR>(id)),GetModuleHandleW(nullptr),nullptr);
   SendMessageW(child,WM_SETFONT,reinterpret_cast<WPARAM>(GetStockObject(DEFAULT_GUI_FONT)),TRUE);
   return child;
  };
  control(SS_LEFT,L"STATIC",L"Flechas arriba y abajo: elegir. Enter: escuchar. Escape: cerrar y volver al juego.",12,10,width-24,36,100);
  control(SS_LEFT,L"STATIC",L"&Sonidos:",12,50,width-24,20,101);
  guide->list=control(WS_TABSTOP|WS_VSCROLL|WS_BORDER|LBS_NOTIFY|LBS_NOINTEGRALHEIGHT,
   L"LISTBOX",L"",12,72,width-24,height-128,102);
  for(const auto& entry:guide->entries)SendMessageW(guide->list,LB_ADDSTRING,0,reinterpret_cast<LPARAM>(entry.label.c_str()));
  SendMessageW(guide->list,LB_SETCURSEL,0,0);
  control(WS_TABSTOP|BS_DEFPUSHBUTTON,L"BUTTON",L"&Reproducir",width-224,height-40,100,28,IDOK);
  control(WS_TABSTOP|BS_PUSHBUTTON,L"BUTTON",L"&Cerrar",width-112,height-40,100,28,IDCANCEL);
  SetTimer(window,1,500,nullptr);SetFocus(guide->list);return FALSE;
 }
 if(message==WM_TIMER){lastUpdate=GetTickCount64();return TRUE;}
 if(message==WM_CLOSE || (message==WM_COMMAND && LOWORD(wp)==IDCANCEL)) {
  KillTimer(window,1);EndDialog(window,IDCANCEL);return TRUE;
 }
 if(message==WM_COMMAND && guide) {
  if(LOWORD(wp)==IDOK || (LOWORD(wp)==102 && HIWORD(wp)==LBN_DBLCLK)) {
   auto selected=SendMessageW(guide->list,LB_GETCURSEL,0,0);
   if(selected!=LB_ERR && static_cast<size_t>(selected)<guide->entries.size()) {
    const auto& entry=guide->entries[static_cast<size_t>(selected)];
    lastUpdate=GetTickCount64();std::lock_guard<std::mutex> lock(gate);
    auto& c=channels[23];c.sound=entry.sound;c.pos=0;c.gain=0;
    c.target=entry.volume;c.pan=entry.pan;c.loop=false;c.playing=true;
   }
   return TRUE;
  }
  if(LOWORD(wp)==102 && HIWORD(wp)==LBN_SELCHANGE) {
   std::lock_guard<std::mutex> lock(gate);channels[23].target=0;return TRUE;
  }
 }
 return FALSE;
}
static int guide(lua_State* L) {
 checkType(L,1,5);size_t count=objectLength(L,1);
 if(count==0 || count>32)return luaError(L,"Catalogo de sonidos fuera de rango");
 GuideDialog data;
 for(size_t i=1;i<=count;i++) {
  rawGetI(L,1,static_cast<int>(i));checkType(L,-1,5);
  getField(L,-1,"id");int id=static_cast<int>(checkNumber(L,-1));setTop(L,-2);
  getField(L,-1,"volume");double volume=checkNumber(L,-1);setTop(L,-2);
  getField(L,-1,"pan");double pan=checkNumber(L,-1);setTop(L,-2);
  getField(L,-1,"label");size_t length;const char* label=checkString(L,-1,&length);
  auto wide=guideWide(label,length);setTop(L,-2);setTop(L,-2);
  if(id<0 || id>=32 || !std::isfinite(volume) || volume<0 || volume>1 ||
     !std::isfinite(pan) || pan<-1 || pan>1 || wide.empty())return luaError(L,"Entrada de sonido invalida");
  bool loaded;{std::lock_guard<std::mutex> lock(gate);loaded=!samples[id].empty();}
  if(!loaded)return luaError(L,"El sonido de la guia no esta cargado");
  data.entries.push_back({id,static_cast<float>(volume),static_cast<float>(pan),std::move(wide)});
 }
 // Zero controls in the template; ordinary accessible Windows controls are
 // created in WM_INITDIALOG. No emulator frames or Lua timers run in this loop.
 struct alignas(DWORD) Template { DLGTEMPLATE dialog; WORD menu=0,windowClass=0,title=0; } layout{};
 layout.dialog.style=WS_POPUP|WS_CAPTION|WS_SYSMENU|DS_MODALFRAME|DS_CENTER;
 layout.dialog.cx=330;layout.dialog.cy=230;
 clear(L);
 auto result=DialogBoxIndirectParamW(GetModuleHandleW(nullptr),&layout.dialog,GetActiveWindow(),guideProc,reinterpret_cast<LPARAM>(&data));
 clear(L);
 if(result==-1)return luaError(L,"No se pudo abrir la guia de sonidos");
 pushBoolean(L,1);return 1;
}
