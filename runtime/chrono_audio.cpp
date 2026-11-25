// Independent Lua 5.1 module: mono PCM cues mixed to stereo on a worker thread.
// No worker ever calls Lua or reads emulator memory.
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <mmsystem.h>
#include <algorithm>
#include <array>
#include <atomic>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <mutex>
#include <string>
#include <thread>
#include <vector>
#pragma comment(lib,"winmm.lib")
#pragma comment(lib,"user32.lib")
#pragma comment(lib,"gdi32.lib")
struct lua_State;
using Fn=int(__cdecl*)(lua_State*);
static const char*(__cdecl*checkString)(lua_State*,int,size_t*);
static double(__cdecl*checkNumber)(lua_State*,int);
static int(__cdecl*toBoolean)(lua_State*,int);
static void(__cdecl*pushBoolean)(lua_State*,int);
static void(__cdecl*pushNumber)(lua_State*,double);
static void(__cdecl*pushClosure)(lua_State*,Fn,int);
static void(__cdecl*setField)(lua_State*,int,const char*);
static void(__cdecl*createTable)(lua_State*,int,int);
static int(__cdecl*luaError)(lua_State*,const char*,...);
struct Channel { int sound=-1; size_t pos=0; float gain=0,target=0,pan=0; bool loop=false,playing=false; };
static std::array<std::vector<int16_t>,32> samples;
static std::array<Channel,24> channels;
static std::mutex gate;
static std::atomic<bool> running(false);
static std::thread worker;
static HWAVEOUT device=nullptr;
static HANDLE eventHandle=nullptr;
static std::atomic<ULONGLONG> lastUpdate(0);
static constexpr int blockFrames=512;
static std::array<std::array<int16_t,blockFrames*2>,4> output;
static std::array<WAVEHDR,4> headers;
static void mix(int16_t* out) {
 std::lock_guard<std::mutex> lock(gate);
 if(GetTickCount64()-lastUpdate.load()>1800)for(auto& c:channels)c.target=0;
 std::array<float,blockFrames*2> mixbuf{};
 for(auto& c:channels) {
  if(!c.playing || c.sound<0) continue;
  if(c.target==0 && c.gain<0.0001f){c.gain=0;c.playing=false;continue;}
  auto& data=samples[c.sound]; if(data.empty()) continue;
  float l=std::cos((c.pan+1)*0.7853981634f),r=std::sin((c.pan+1)*0.7853981634f);
  for(int f=0;f<blockFrames;f++) {
   if(c.pos>=data.size()) { if(c.loop)c.pos=0; else {c.playing=false;break;} }
   c.gain+=(c.target-c.gain)*0.002f;
   float sample=data[c.pos++]*c.gain;
   mixbuf[2*f]+=sample*l;mixbuf[2*f+1]+=sample*r;
  }
 }
 for(int i=0;i<blockFrames*2;i++) out[i]=static_cast<int16_t>(std::clamp(mixbuf[i],-32767.f,32767.f));
}
static void loop() {
 std::array<bool,4> queued{};
 while(running) {
  for(int i=0;i<4 && running;i++) {
   if(!queued[i] || (headers[i].dwFlags&WHDR_DONE)) {
    mix(output[i].data());
    if(waveOutWrite(device,&headers[i],sizeof(WAVEHDR))!=MMSYSERR_NOERROR) { running=false;break; }
    queued[i]=true;
   }
  }
  WaitForSingleObject(eventHandle,25);
 }
}
static void shutdown() {
 running=false;if(eventHandle)SetEvent(eventHandle);
 if(worker.joinable())worker.join();
 if(device) {
  waveOutReset(device);
  for(auto& h:headers) if(h.dwFlags&WHDR_PREPARED)waveOutUnprepareHeader(device,&h,sizeof(h));
  waveOutClose(device);device=nullptr;
 }
 if(eventHandle){CloseHandle(eventHandle);eventHandle=nullptr;}
 std::lock_guard<std::mutex> lock(gate);channels={};
}
static int init(lua_State* L) {
 if(device){pushBoolean(L,1);return 1;}
 WAVEFORMATEX fmt{};fmt.wFormatTag=WAVE_FORMAT_PCM;fmt.nChannels=2;fmt.nSamplesPerSec=22050;
 fmt.wBitsPerSample=16;fmt.nBlockAlign=4;fmt.nAvgBytesPerSec=88200;
 eventHandle=CreateEventW(nullptr,FALSE,FALSE,nullptr);
 if(!eventHandle)return luaError(L,"No se pudo crear el evento de audio");
 MMRESULT result=waveOutOpen(&device,WAVE_MAPPER,&fmt,reinterpret_cast<DWORD_PTR>(eventHandle),0,CALLBACK_EVENT);
 if(result!=MMSYSERR_NOERROR){shutdown();return luaError(L,"No se pudo abrir el audio: %d",result);}
 headers={};
 for(int i=0;i<4;i++) {
  headers[i].lpData=reinterpret_cast<LPSTR>(output[i].data());headers[i].dwBufferLength=blockFrames*4;
  result=waveOutPrepareHeader(device,&headers[i],sizeof(WAVEHDR));
  if(result!=MMSYSERR_NOERROR){shutdown();return luaError(L,"No se pudo preparar el audio: %d",result);}
 }
 running=true;
 try {worker=std::thread(loop);}catch(...){shutdown();return luaError(L,"No se pudo iniciar el mezclador");}
 pushBoolean(L,1);return 1;
}
static uint32_t u32(const unsigned char* p){uint32_t n;std::memcpy(&n,p,4);return n;}
static uint16_t u16(const unsigned char* p){uint16_t n;std::memcpy(&n,p,2);return n;}
static int load(lua_State* L) {
 int id=static_cast<int>(checkNumber(L,1));size_t length;const char* path=checkString(L,2,&length);
 if(id<0||id>=32)return luaError(L,"Identificador de sonido fuera de rango");
 std::vector<int16_t> pcm;bool valid=false;
 {
  int n=MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,path,static_cast<int>(length),nullptr,0);
  std::wstring wide(n,L'\0');
  if(n)MultiByteToWideChar(CP_UTF8,0,path,static_cast<int>(length),wide.data(),n);
  std::ifstream file(wide,std::ios::binary|std::ios::ate);
  if(file && file.tellg()>12 && file.tellg()<16000000) {
   std::vector<unsigned char> bytes(static_cast<size_t>(file.tellg()));file.seekg(0);file.read(reinterpret_cast<char*>(bytes.data()),bytes.size());
   if(file && !std::memcmp(bytes.data(),"RIFF",4) && !std::memcmp(bytes.data()+8,"WAVE",4)) {
    bool format=false;size_t dataOffset=0,dataLength=0;
    for(size_t p=12;p+8<=bytes.size();) {
     size_t len=u32(bytes.data()+p+4);if(len>bytes.size()-p-8)break;
     if(!std::memcmp(bytes.data()+p,"fmt ",4)&&len>=16) {
      const auto* q=bytes.data()+p+8;
      format=u16(q)==1&&u16(q+2)==1&&u32(q+4)==22050&&u16(q+14)==16;
     }
     if(!std::memcmp(bytes.data()+p,"data",4)){dataOffset=p+8;dataLength=len;}
     p+=8+len+(len%2);
    }
    if(format && dataLength>0 && dataLength%2==0) {
     pcm.resize(dataLength/2);std::memcpy(pcm.data(),bytes.data()+dataOffset,dataLength);valid=true;
    }
   }
  }
 }
 if(!valid)return luaError(L,"No se pudo leer WAV mono PCM de 22050 Hz: %s",path);
 {std::lock_guard<std::mutex> lock(gate);samples[id]=std::move(pcm);}
 pushBoolean(L,1);return 1;
}
static int set(lua_State* L) {
 int slot=static_cast<int>(checkNumber(L,1)),id=static_cast<int>(checkNumber(L,2));
 double volume=checkNumber(L,3),pan=checkNumber(L,4);bool repeat=toBoolean(L,5)!=0;
 if(slot<0||slot>=24||id<0||id>=32||!std::isfinite(volume)||!std::isfinite(pan))return luaError(L,"Parametros de audio invalidos");
 lastUpdate=GetTickCount64();bool loaded;
 {
  std::lock_guard<std::mutex> lock(gate);loaded=!samples[id].empty();
  if(loaded){auto& c=channels[slot];if(c.sound!=id||!c.playing||!repeat){c.pos=0;c.gain=0;}
   c.sound=id;c.pan=static_cast<float>(std::clamp(pan,-1.,1.));c.target=static_cast<float>(std::clamp(volume,0.,1.));c.loop=repeat;c.playing=true;}
 }
 if(!loaded)return luaError(L,"El sonido no esta cargado");
 pushBoolean(L,1);return 1;
}
static int clear(lua_State*){lastUpdate=GetTickCount64();std::lock_guard<std::mutex> lock(gate);for(auto& c:channels)c.target=0;return 0;}
static int close(lua_State*){shutdown();return 0;}
static int now(lua_State* L){pushNumber(L,static_cast<double>(GetTickCount64())/1000.0);return 1;}
#include "sound-guide-dialog.h"
extern "C" __declspec(dllexport) int luaopen_chrono_audio(lua_State* L) {
 HMODULE lua=GetModuleHandleW(L"lua5.1.dll");if(!lua)lua=GetModuleHandleW(L"lua51.dll");if(!lua)return 0;
#define GET(v,n) v=reinterpret_cast<decltype(v)>(GetProcAddress(lua,n));if(!v)return 0
 GET(checkString,"luaL_checklstring");GET(checkNumber,"luaL_checknumber");GET(toBoolean,"lua_toboolean");
 GET(pushBoolean,"lua_pushboolean");GET(pushClosure,"lua_pushcclosure");GET(setField,"lua_setfield");
 GET(pushNumber,"lua_pushnumber");
 GET(createTable,"lua_createtable");GET(luaError,"luaL_error");
 GET(getField,"lua_getfield");GET(rawGetI,"lua_rawgeti");GET(setTop,"lua_settop");
 GET(objectLength,"lua_objlen");GET(checkType,"luaL_checktype");
#undef GET
 createTable(L,0,6);
 pushClosure(L,init,0);setField(L,-2,"init");pushClosure(L,load,0);setField(L,-2,"load");
 pushClosure(L,set,0);setField(L,-2,"set");pushClosure(L,clear,0);setField(L,-2,"clear");
 pushClosure(L,close,0);setField(L,-2,"shutdown");pushClosure(L,now,0);setField(L,-2,"now");
 pushClosure(L,guide,0);setField(L,-2,"guide");return 1;
}
